import CloudCore
import Foundation
import Observation
import Persistence

enum RandomExploreMediaFilter: String, CaseIterable, Hashable, Sendable {
    case all, photos, videos

    var title: String {
        switch self {
        case .all: String(localized: "All")
        case .photos: String(localized: "Photos")
        case .videos: String(localized: "Videos")
        }
    }

    var cloudType: CloudRandomMediaType? {
        switch self {
        case .all: nil
        case .photos: .image
        case .videos: .video
        }
    }
}

enum RandomExploreDateRange: String, CaseIterable, Hashable, Sendable {
    case all
    case lastYear
    case yearsOneToThree
    case yearsThreeToFive
    case yearsFiveToTen
    case olderThanTen
    case custom

    var title: String {
        switch self {
        case .all: String(localized: "All Dates")
        case .lastYear: String(localized: "Last Year")
        case .yearsOneToThree: String(localized: "1–3 Years Ago")
        case .yearsThreeToFive: String(localized: "3–5 Years Ago")
        case .yearsFiveToTen: String(localized: "5–10 Years Ago")
        case .olderThanTen: String(localized: "More Than 10 Years Ago")
        case .custom: String(localized: "Custom")
        }
    }
}

struct RandomExploreFilters: Equatable, Sendable {
    var albumID = ""
    var media = RandomExploreMediaFilter.all
    var dateRange = RandomExploreDateRange.all
    var startDate: Date?
    var endDate: Date?

    var query: CloudRandomSearchQuery {
        var query = CloudRandomSearchQuery(albumID: albumID.isEmpty ? nil : albumID, mediaType: media.cloudType)
        let calendar = Calendar.autoupdatingCurrent
        let now = Date.now
        func yearsAgo(_ years: Int) -> Date? {
            calendar.date(byAdding: .year, value: -years, to: now)
        }

        switch dateRange {
        case .all:
            break
        case .lastYear:
            query.takenAfter = yearsAgo(1)
            query.takenBefore = now
        case .yearsOneToThree:
            query.takenAfter = yearsAgo(3)
            query.takenBefore = yearsAgo(1)
        case .yearsThreeToFive:
            query.takenAfter = yearsAgo(5)
            query.takenBefore = yearsAgo(3)
        case .yearsFiveToTen:
            query.takenAfter = yearsAgo(10)
            query.takenBefore = yearsAgo(5)
        case .olderThanTen:
            query.takenBefore = yearsAgo(10)
        case .custom:
            let start = startDate.map(calendar.startOfDay(for:))
            let end = endDate.map(calendar.startOfDay(for:))
            switch (start, end) {
            case let (start?, end?) where start > end:
                query.takenAfter = end
                query.takenBefore = calendar.date(byAdding: .day, value: 1, to: start)
            case let (start?, end?):
                query.takenAfter = start
                query.takenBefore = calendar.date(byAdding: .day, value: 1, to: end)
            case let (start?, nil):
                query.takenAfter = start
            case let (nil, end?):
                query.takenBefore = calendar.date(byAdding: .day, value: 1, to: end)
            case (nil, nil):
                break
            }
        }
        return query
    }
}

/// State for one Random Explore round. Each request is server-side random and
/// only the small batches needed by the grid or viewer are retained.
@MainActor
@Observable
final class RandomExploreModel {
    static let batchSize = 60
    private static let maxDuplicateBatches = 3

    let session: LibrarySession
    var filters = RandomExploreFilters()
    private(set) var items: [TimelineItem] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var isExhausted = false
    private(set) var errorMessage: String?
    private(set) var revision = 0

    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var seenIDs = Set<String>()
    @ObservationIgnored private var duplicateBatches = 0
    @ObservationIgnored private var batchTask: Task<[TimelineItem], Never>?
    @ObservationIgnored private var batchRequestID = 0

    init(session: LibrarySession) {
        self.session = session
    }

    func start() async {
        guard !hasLoaded else { return }
        await resetAndLoad()
    }

    func shuffle() async {
        await resetAndLoad()
    }

    func resetAndLoad() async {
        generation += 1
        batchTask?.cancel()
        batchTask = nil
        batchRequestID += 1
        items = []
        revision += 1
        seenIDs = []
        duplicateBatches = 0
        isExhausted = false
        hasLoaded = false
        errorMessage = nil
        _ = await loadNextBatch()
    }

    /// Returns the assets added by this batch so an already-open viewer can extend
    /// its pager with exactly the same order as the grid.
    @discardableResult
    func loadNextBatch() async -> [TimelineItem] {
        guard !isExhausted else { return [] }
        if let batchTask { return await batchTask.value }

        let requestID = batchRequestID + 1
        batchRequestID = requestID
        let round = generation
        isLoading = true
        let task = Task { [weak self] in
            guard let self else { return [] }
            return await self.fetchBatch(round: round)
        }
        batchTask = task
        let result = await task.value
        if batchRequestID == requestID { batchTask = nil }
        return result
    }

    private func fetchBatch(round: Int) async -> [TimelineItem] {
        defer {
            if round == generation {
                isLoading = false
                hasLoaded = true
            }
        }

        for _ in 0..<Self.maxDuplicateBatches {
            guard !Task.isCancelled, round == generation else { return [] }
            let raw: [TimelineItem]
            do {
                raw = try await session.randomExploreItems(filters.query, limit: Self.batchSize)
            } catch is CancellationError {
                return []
            } catch {
                if round == generation {
                    errorMessage = (error as? CloudError)?.message ?? error.localizedDescription
                }
                return []
            }

            guard !Task.isCancelled, round == generation else { return [] }
            if raw.isEmpty {
                isExhausted = true
                return []
            }

            let fresh = raw.filter { seenIDs.insert($0.id).inserted }
            if !fresh.isEmpty {
                items.append(contentsOf: fresh)
                revision += 1
                duplicateBatches = 0
                if raw.count < Self.batchSize { isExhausted = true }
                errorMessage = nil
                return fresh
            }

            duplicateBatches += 1
            if raw.count < Self.batchSize { isExhausted = true; return [] }
        }

        // A small library can return the same full batch repeatedly. Stop after a
        // bounded number of attempts instead of spinning forever.
        isExhausted = true
        return []
    }
}

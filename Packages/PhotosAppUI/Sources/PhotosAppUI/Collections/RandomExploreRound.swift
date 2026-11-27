import CloudCore
import Foundation
import Observation
import Persistence

struct RandomExploreFilter: Equatable {
    enum Media: CaseIterable { case all, photos, videos }
    enum Range: CaseIterable { case all, pastYear, oneToThree, threeToFive, fiveToTen, overTen, custom }

    var albumID: String?
    var media = Media.all
    var range = Range.all
    var start: Date?
    var end: Date?

    func query(now: Date = .now, calendar: Calendar = .current) -> CloudRandomQuery {
        let lower: Date?, upper: Date?
        func yearsAgo(_ years: Int) -> Date? { calendar.date(byAdding: .year, value: -years, to: now) }
        switch range {
        case .all: (lower, upper) = (nil, nil)
        case .pastYear: (lower, upper) = (yearsAgo(1), now)
        case .oneToThree: (lower, upper) = (yearsAgo(3), yearsAgo(1))
        case .threeToFive: (lower, upper) = (yearsAgo(5), yearsAgo(3))
        case .fiveToTen: (lower, upper) = (yearsAgo(10), yearsAgo(5))
        case .overTen: (lower, upper) = (nil, yearsAgo(10))
        case .custom:
            var first = start.map(calendar.startOfDay(for:))
            var last = end.map(calendar.startOfDay(for:))
            if let a = first, let b = last, a > b { swap(&first, &last) }
            lower = first
            // Gallery's third-party client contract uses inclusive fileCreatedAt bounds.
            // Calendar days can be 23 or 25 hours; do not add 86,400 seconds.
            upper = last.flatMap { calendar.dateInterval(of: .day, for: $0)?.end.addingTimeInterval(-0.001) }
        }
        let video: Bool? = switch media { case .all: nil; case .photos: false; case .videos: true }
        return CloudRandomQuery(albumID: albumID, isVideo: video, takenAfter: lower, takenBefore: upper)
    }
}

/// One append-only server sample shared by the grid and its presented pager.
@MainActor @Observable
final class RandomExploreRound {
    private(set) var items: [TimelineItem] = []
    private(set) var roundID = UUID()
    private(set) var version = 0
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var isExhausted = false
    @ObservationIgnored private var seen: Set<String> = []
    @ObservationIgnored private var query = CloudRandomQuery()
    @ObservationIgnored private var request: Task<Void, Never>?
    private let load: @MainActor (CloudRandomQuery, Int) async throws -> [TimelineItem]

    init(load: @escaping @MainActor (CloudRandomQuery, Int) async throws -> [TimelineItem]) { self.load = load }
    deinit { request?.cancel() }

    @discardableResult
    func restart(query: CloudRandomQuery) -> Task<Void, Never> {
        request?.cancel()
        roundID = UUID()
        self.query = query
        items.removeAll()
        seen.removeAll()
        version += 1
        isExhausted = false
        return fetch()
    }

    @discardableResult
    func prefetch(near index: Int) -> Task<Void, Never>? {
        guard items.indices.contains(index), items.count - 1 - index <= 72,
              !isLoading, !isExhausted, errorMessage == nil else { return nil }
        return fetch()
    }

    @discardableResult
    func retry() -> Task<Void, Never>? {
        guard errorMessage != nil, !isLoading else { return nil }
        return fetch()
    }

    @discardableResult
    private func fetch() -> Task<Void, Never> {
        isLoading = true
        errorMessage = nil
        let task = Task { [weak self, roundID, query, load] in
            do {
                let batch = try await load(query, 200)
                guard let self, self.roundID == roundID else { return }
                let oldCount = items.count
                for item in batch where seen.insert(item.id).inserted { items.append(item) }
                if items.count == oldCount { isExhausted = true } else { version += 1 }
            } catch {
                guard let self, self.roundID == roundID else { return }
                errorMessage = CloudError.message(for: error)
            }
            self?.isLoading = false
            self?.request = nil
        }
        request = task
        return task
    }
}

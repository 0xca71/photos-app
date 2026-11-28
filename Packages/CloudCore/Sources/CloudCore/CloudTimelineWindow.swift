import Foundation
import Persistence

/// A contiguous window into one immutable filter/order. Bucket counts index the entire
/// server result, not just the window rendered by the grid. No database or sync state.
public struct CloudTimelineWindow: Sendable {
    private let source: any CloudTimelineBrowsing
    private let query: CloudTimelineQuery
    private let buckets: [CloudTimelineBucket]
    private var range: Range<Int> = 0..<0
    private var startOffset = 0
    public private(set) var items: [TimelineItem] = []
    public private(set) var revision = 0
    /// Nil until client-only predicates have been evaluated for all buckets.
    public private(set) var count: Int?
    public var hasOlder: Bool { range.lowerBound > 0 }
    public var hasNewer: Bool { range.upperBound < buckets.count }

    public init(source: any CloudTimelineBrowsing, query: CloudTimelineQuery) async throws {
        self.source = source
        self.query = query
        buckets = try await source.timelineBuckets(query).filter { $0.count > 0 }
        range = buckets.endIndex..<buckets.endIndex
        count = query.hasClientFilter && !buckets.isEmpty ? nil : buckets.reduce(0) { $0 + $1.count }
        startOffset = count ?? 0
    }

    private func rows(in index: Int) async throws -> [TimelineItem] {
        try Task.checkCancellation()
        let rows = try await source.timelineItems(buckets[index], query: query)
        // A mutation between summary and bucket must not move an index into a different asset set.
        guard query.hasClientFilter || rows.count == buckets[index].count else {
            throw CloudError(kind: .decoding, message: String(localized: "The timeline changed. Please try again."))
        }
        return rows
    }

    /// Extend by one nonempty bucket (or reach the end). Newest bucket first on launch.
    public mutating func extend(older: Bool) async throws {
        while older ? hasOlder : hasNewer {
            let index = older ? range.lowerBound - 1 : range.upperBound
            let rows = try await rows(in: index)
            if older {
                range = index..<range.upperBound
                items.insert(contentsOf: rows, at: 0)
                if !query.hasClientFilter { startOffset -= rows.count }
            } else {
                range = range.lowerBound..<(index + 1)
                items.append(contentsOf: rows)
            }
            revision += 1
            if !hasOlder && !hasNewer { count = items.count }
            if !rows.isEmpty { break }
        }
    }

    /// For predicates Gallery can't count (e.g. camera EXIF), gather only matching
    /// rows before drawing. Reuse the current window; never sample a partially filtered page.
    public mutating func loadAll() async throws {
        guard hasOlder || hasNewer else { return }
        var before: [TimelineItem] = []
        for index in 0..<range.lowerBound { before.append(contentsOf: try await rows(in: index)) }
        if !before.isEmpty { items.insert(contentsOf: before, at: 0) }
        for index in range.upperBound..<buckets.count { items.append(contentsOf: try await rows(in: index)) }
        range = buckets.indices
        startOffset = 0
        count = items.count
        revision += 1
    }

    /// Resolve an absolute filtered ordinal to an index in the displayed window. Only a
    /// distant month's metadata needs loading; a hit in the current window requires no I/O.
    private mutating func locate(_ ordinal: Int) async throws -> Int {
        if items.indices.contains(ordinal - startOffset) { return ordinal - startOffset }
        var offset = 0
        for (index, bucket) in buckets.enumerated() {
            if ordinal - offset < bucket.count {
                items = try await rows(in: index)
                range = index..<(index + 1)
                startOffset = offset
                revision += 1
                return ordinal - offset
            }
            offset += bucket.count
        }
        throw CloudError(kind: .decoding, message: String(localized: "The timeline changed. Please try again."))
    }

    public mutating func randomIndex(previousID: String?) async throws -> Int? {
        try await randomIndex(previousID: previousID) { Int.random(in: 0..<$0) }
    }

    mutating func randomIndex(previousID: String?, draw: @Sendable (Int) -> Int) async throws -> Int? {
        if count == nil { try await loadAll() }
        guard let count, count > 0 else { return nil }
        let first = draw(count)
        let index = try await locate(first)
        if count == 1 || items[index].id != previousID { return index }
        let other = draw(count - 1)
        return try await locate(other >= first ? other + 1 : other)
    }
}

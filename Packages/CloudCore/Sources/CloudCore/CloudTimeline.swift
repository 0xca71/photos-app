import Persistence

/// A read-only capability, independent of uploads and library sync.
public protocol CloudTimelineBrowsing: Sendable {
    /// Visible buckets, oldest first. Counts do not include client-side narrowing.
    func timelineBuckets(_ query: CloudTimelineQuery) async throws -> [CloudTimelineBucket]
    /// All matching remote rows from this bucket, oldest first in the requested order.
    /// Classification metadata is resolved for this query; do not re-filter rows for another query.
    func timelineItems(_ bucket: CloudTimelineBucket, query: CloudTimelineQuery) async throws -> [TimelineItem]
}

/// A narrowing of the signed-in account's visible server timeline, not a global asset search.
public enum CloudTimelineFilter: Hashable, Sendable {
    case all, favourites, edited, sharedWithYou, capturedByMe, notInAlbum, photos, videos, screenshots
}

public struct CloudTimelineQuery: Hashable, Sendable {
    public let userID: String
    public let filter: CloudTimelineFilter
    public let addedOrder: Bool
    public let showScreenshots: Bool
    public let showShared: Bool

    public init(userID: String, filter: CloudTimelineFilter, addedOrder: Bool, showScreenshots: Bool, showShared: Bool) {
        self.userID = userID
        self.filter = filter
        self.addedOrder = addedOrder
        self.showScreenshots = showScreenshots
        self.showShared = showShared
    }

    /// Whether matching rows still need to be counted after loading a server bucket.
    public var hasClientFilter: Bool {
        if !showScreenshots && filter != .videos { return true }
        switch filter {
        case .edited, .sharedWithYou, .capturedByMe, .screenshots: return true
        case .all, .favourites, .notInAlbum, .photos, .videos: return false
        }
    }
}

public struct CloudTimelineBucket: Equatable, Sendable {
    /// Opaque to the caller. Pass it back to the same server with the same query.
    public let timeBucket: String
    /// The raw number of rows before any client-only predicates.
    public let count: Int

    public init(timeBucket: String, count: Int) {
        self.timeBucket = timeBucket
        self.count = count
    }
}

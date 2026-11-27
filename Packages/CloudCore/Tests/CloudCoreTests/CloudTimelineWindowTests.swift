import Foundation
import Persistence
import Testing
@testable import CloudCore

@Suite struct CloudTimelineWindowTests {
    private actor Source: CloudTimelineBrowsing {
        let pages: [[String]]
        let rawCounts: [Int]
        private(set) var reads: [Int] = []

        init(_ pages: [[String]], rawCounts: [Int]? = nil) {
            self.pages = pages
            self.rawCounts = rawCounts ?? pages.map(\.count)
        }
        func timelineBuckets(_ query: CloudTimelineQuery) -> [CloudTimelineBucket] {
            rawCounts.enumerated().map { .init(timeBucket: String($0.offset), count: $0.element) }
        }
        func timelineItems(_ bucket: CloudTimelineBucket, query: CloudTimelineQuery) -> [TimelineItem] {
            let page = Int(bucket.timeBucket)!
            reads.append(page)
            return pages[page].map {
                TimelineItem(id: $0, date: .distantPast, isVideo: false, durationMs: nil, isFavorite: true,
                             isLivePhoto: false, thumbhash: nil, aspectRatio: 1)
            }
        }
    }

    private func query(_ filter: CloudTimelineFilter = .favourites) -> CloudTimelineQuery {
        .init(userID: "owner", filter: filter, addedOrder: false, showScreenshots: true, showShared: true)
    }

    @Test func emptyAndSingleton() async throws {
        var empty = try await CloudTimelineWindow(source: Source([]), query: query())
        #expect(try await empty.randomIndex(previousID: nil) == nil)
        var single = try await CloudTimelineWindow(source: Source([["only"]]), query: query())
        #expect(try await single.randomIndex(previousID: "only") == 0)
        #expect(single.items.map(\.id) == ["only"])
    }

    @Test func everyOrdinalAcrossUnequalBucketsIsReachableFromTheNewestPage() async throws {
        let pages = [["a", "b"], ["c"], ["d", "e", "f"]]
        let source = Source(pages)
        let expected = pages.flatMap { $0 }
        var window = try await CloudTimelineWindow(source: source, query: query())
        try await window.extend(older: true)
        #expect(window.items.map(\.id) == ["d", "e", "f"])
        for ordinal in expected.indices {
            let index = try #require(try await window.randomIndex(previousID: nil) { _ in ordinal })
            #expect(window.items[index].id == expected[ordinal])
        }
        #expect(await source.reads == [2, 0, 1, 2])
    }

    @Test func twoItemsNeverRepeatEvenAcrossPages() async throws {
        var window = try await CloudTimelineWindow(source: Source([["a"], ["b"]]), query: query())
        for previous in ["a", "b", "a", "b"] {
            let index = try #require(try await window.randomIndex(previousID: previous) { _ in 0 })
            #expect(window.items[index].id == (previous == "a" ? "b" : "a"))
        }
    }

    @Test func clientFilterSamplesMatchedRowsNotRawCountsOrCurrentPage() async throws {
        let source = Source([["old edit"], [], ["new edit"]], rawCounts: [50, 31, 8])
        var window = try await CloudTimelineWindow(source: source, query: query(.edited))
        try await window.extend(older: true)
        #expect(window.count == nil && window.items.map(\.id) == ["new edit"])
        let index = try #require(try await window.randomIndex(previousID: "new edit") { $0 - 1 })
        #expect(window.count == 2 && window.items[index].id == "old edit")
        #expect(await source.reads == [2, 0, 1])
    }

    @Test func serverMutationCannotReturnAnOutOfBoundsTarget() async throws {
        var window = try await CloudTimelineWindow(source: Source([["one"]], rawCounts: [2]), query: query())
        await #expect(throws: CloudError.self) {
            _ = try await window.randomIndex(previousID: nil) { $0 - 1 }
        }
    }
}

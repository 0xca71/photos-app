import CloudCore
import Foundation
import Persistence
import Testing
@testable import PhotosAppUI

@Suite @MainActor
struct RandomExploreRoundTests {
    private func date(_ value: String) -> Date { ISO8601DateFormatter().date(from: value)! }
    private func item(_ id: String) -> TimelineItem {
        TimelineItem(id: id, date: .distantPast, isVideo: false, durationMs: nil, isFavorite: false,
                     isLivePhoto: false, thumbhash: nil, aspectRatio: 1)
    }

    @Test func combinedFilterUsesEntireLocalDaysAcrossDST() {
        var la = Calendar(identifier: .gregorian)
        la.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        // Entered backwards; the end of March 10 follows a 23-hour day.
        var filter = RandomExploreFilter(albumID: "trips", media: .videos, range: .custom,
                                         start: date("2024-03-10T16:00:00Z"), end: date("2024-03-09T16:00:00Z"))
        let midnight = date("2024-03-11T07:00:00Z")
        #expect(filter.query(calendar: la) == CloudRandomQuery(albumID: "trips", isVideo: true,
                 takenAfter: date("2024-03-09T08:00:00Z"), takenBefore: midnight.addingTimeInterval(-0.001)))
        filter.start = nil
        #expect(filter.query(calendar: la).takenAfter == nil)
        filter.end = nil
        #expect(filter.query(calendar: la).takenBefore == nil)
    }

    @Test func presetsUseCalendarYearsAndPreserveOtherFilters() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = .gmt
        let now = date("2024-02-29T06:00:00Z")
        let bounds: [(RandomExploreFilter.Range, Int?, Int?)] = [
            (.pastYear, 1, 0), (.oneToThree, 3, 1), (.threeToFive, 5, 3),
            (.fiveToTen, 10, 5), (.overTen, nil, 10), (.all, nil, nil),
        ]
        for (range, lower, upper) in bounds {
            let filter = RandomExploreFilter(albumID: "family", media: .photos, range: range)
            func ago(_ years: Int) -> Date { date(years == 0 ? "2024-02-29T06:00:00Z" : "\(2024-years)-02-28T06:00:00Z") }
            #expect(filter.query(now: now, calendar: utc) == CloudRandomQuery(albumID: "family", isVideo: false,
                     takenAfter: lower.map(ago), takenBefore: upper.map(ago)))
        }
    }

    @Test func shuffleAndFilterReplacePendingRequestsEvenIfCancellationIsIgnored() async throws {
        struct Request {
            let query: CloudRandomQuery
            let reply: CheckedContinuation<[TimelineItem], any Error>
        }
        let requests = AsyncStream<Request>.makeStream()
        var next = requests.stream.makeAsyncIterator()
        let round = RandomExploreRound { query, _ in
            try await withCheckedThrowingContinuation { requests.continuation.yield(Request(query: query, reply: $0)) }
        }
        let photos = CloudRandomQuery(albumID: "small", isVideo: false)
        let first = round.restart(query: photos)
        let initial = try #require(await next.next())
        initial.reply.resume(returning: [item("one"), item("two")])
        await first.value

        let more = try #require(round.prefetch(near: 1))
        let lateBatch = try #require(await next.next())
        #expect(round.prefetch(near: 0) == nil)
        let shuffle = round.restart(query: photos)
        #expect(round.items.isEmpty)
        let shuffled = try #require(await next.next())
        #expect(shuffled.query == photos)
        shuffled.reply.resume(returning: [item("shuffle-only"), item("one")])
        await shuffle.value
        lateBatch.reply.resume(returning: [item("must-not-append")])
        await more.value
        #expect(round.items.map(\.id) == ["shuffle-only", "one"])

        let lateFailure = try #require(round.prefetch(near: 1))
        let failing = try #require(await next.next())
        let videos = CloudRandomQuery(albumID: "other", isVideo: true)
        let replacement = round.restart(query: videos)
        let changed = try #require(await next.next())
        #expect(changed.query == videos)
        failing.reply.resume(throwing: URLError(.cancelled))
        await lateFailure.value
        #expect(round.isLoading && round.errorMessage == nil)
        changed.reply.resume(returning: [item("video")])
        await replacement.value
        #expect(round.items.map(\.id) == ["video"])
    }

    @Test func smallPoolPreservesServerOrderAndStopsOnAnAllDuplicateBatch() async throws {
        var batches = [["z", "a", "z"], ["a", "m", "m", "b"], ["m", "z"]]
        let round = RandomExploreRound { _, _ in batches.removeFirst().map(item) }
        await round.restart(query: CloudRandomQuery()).value
        #expect(round.items.map(\.id) == ["z", "a"])
        let append = try #require(round.prefetch(near: 1))
        await append.value
        #expect(round.items.map(\.id) == ["z", "a", "m", "b"])
        let repeatOnly = try #require(round.prefetch(near: 2))
        await repeatOnly.value
        #expect(round.isExhausted && round.prefetch(near: 3) == nil)
        #expect(round.items.map(\.id) == ["z", "a", "m", "b"])
    }

    @Test func emptyResponseStopsAndFailedAppendWaitsForUserRetry() async throws {
        var samples: [Result<[TimelineItem], URLError>] = [.success([]), .success([item("keep")]), .failure(URLError(.timedOut))]
        let round = RandomExploreRound { _, _ in try samples.removeFirst().get() }
        await round.restart(query: CloudRandomQuery()).value
        #expect(round.isExhausted && round.items.isEmpty && round.prefetch(near: 0) == nil)
        await round.restart(query: CloudRandomQuery()).value
        let fail = try #require(round.prefetch(near: 0))
        await fail.value
        #expect(round.errorMessage != nil && round.prefetch(near: 0) == nil)
        #expect(round.items.map(\.id) == ["keep"])
        samples.append(.success([item("new")]))
        let retry = try #require(round.retry())
        await retry.value
        #expect(round.items.map(\.id) == ["keep", "new"] && round.errorMessage == nil)
    }
}

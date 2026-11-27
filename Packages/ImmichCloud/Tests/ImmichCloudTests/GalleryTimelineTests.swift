import CloudCore
import Foundation
import Testing
@testable import ImmichCloud

@Suite struct GalleryTimelineTests {
    private let server = URL(string: "https://nas.example/photos")!
    private let bucket = CloudTimelineBucket(timeBucket: "2025-01-01", count: 3)

    private func query(_ filter: CloudTimelineFilter, added: Bool = false, screenshots: Bool = true, shared: Bool = true) -> CloudTimelineQuery {
        .init(userID: "me", filter: filter, addedOrder: added, showScreenshots: screenshots, showShared: shared)
    }

    @Test func bothRoutesReceiveExactlyTheSameServerScope() async throws {
        let base = ["userId": "me", "visibility": "timeline", "withStacked": "true", "bucketSize": "month", "order": "asc"]
        let shared = ["withPartners": "true", "withSharedSpaces": "true"]
        let examples: [(CloudTimelineQuery, [String: String], Bool)] = [
            (query(.all), shared, false),
            (query(.favourites), ["isFavorite": "true"], false),
            (query(.notInAlbum), shared.merging(["isNotInAlbum": "true"]) { _, v in v }, false),
            (query(.photos, added: true, shared: false), ["type": "IMAGE", "ownerId": "me"], false),
            (query(.videos, screenshots: false), shared.merging(["type": "VIDEO"]) { _, v in v }, false),
            (query(.screenshots), shared.merging(["type": "IMAGE"]) { _, v in v }, true),
            (query(.edited), shared, true), (query(.all, screenshots: false), shared, true),
            (query(.capturedByMe), shared.merging(["ownerId": "me"]) { _, v in v }, true),
            (query(.sharedWithYou), shared, true),
        ]
        for (query, additions, hasClientFilter) in examples {
            let transport = Transport(rows: [])
            let api = GalleryTimeline(server: server, token: "session-token", send: transport.send)
            let buckets = try await api.buckets(query)
            #expect(buckets == [.init(timeBucket: "2025-01-01", count: 3), .init(timeBucket: "2025-02-01", count: 1)])
            #expect(try await api.items(bucket, query: query).isEmpty)
            #expect(query.hasClientFilter == hasClientFilter)
            let requests = await transport.requests
            #expect(requests.map { $0.url?.path } == ["/photos/api/timeline/buckets", "/photos/api/timeline/bucket"])
            var expected = base.merging(additions) { _, v in v }
            expected["orderBy"] = query.addedOrder ? "createdAt" : "takenAt"
            for request in requests {
                let url = try #require(request.url)
                let params = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
                if url.lastPathComponent == "bucket" { expected["timeBucket"] = bucket.timeBucket }
                #expect(Dictionary(uniqueKeysWithValues: params.map { ($0.name, $0.value ?? "") }) == expected)
                #expect(request.httpMethod == "GET")
                #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer session-token")
            }
        }
    }

    @Test func columnarRowsNeedNoDetailsForOrdinaryBrowse() async throws {
        let transport = Transport(rows: Row.examples)
        let api = GalleryTimeline(server: server, token: "token", send: transport.send)
        let items = try await api.items(bucket, query: query(.all))
        // UTC order in the response; offsets put the camera photo before the screen capture in the native grid.
        #expect(items.map(\.id) == ["camera", "shot", "video"])
        let camera = try #require(items.first)
        #expect(camera.date == Date(timeIntervalSince1970: 1_735_747_200)) // Jan 1, 2025 16:00 UTC
        #expect(camera.ownerID == "partner" && camera.localID == nil && camera.isRemote)
        #expect(camera.isLivePhoto && camera.aspectRatio == 1.5 && camera.thumbhash == "abc=")
        let video = try #require(items.last)
        #expect(video.isVideo && video.durationMs == 2405 && video.isFavorite)
        #expect(video.uploadedAt == Date(timeIntervalSince1970: 1_735_819_200)) // Jan 2, 2025 12:00 UTC
        #expect(await transport.paths == ["bucket"])
    }

    @Test func nativePredicatesResolveOnlyCandidateDetails() async throws {
        let examples: [(CloudTimelineQuery, [String], Set<String>)] = [
            (query(.screenshots), ["shot"], ["shot", "camera"]),
            (query(.all, screenshots: false), ["camera", "video"], ["shot", "camera"]),
            (query(.edited), ["camera"], ["shot", "camera", "video"]),
            (query(.sharedWithYou), ["camera"], []),
            (query(.all, shared: false), ["shot", "video"], []),
            (query(.capturedByMe), ["video"], ["shot", "video"]),
            (query(.favourites), ["video"], []),
            (query(.videos, screenshots: false), ["video"], []),
        ]
        // Even when the fixture returns unexpected rows, only the server-account-visible candidates survive.
        var hidden = Row(id: "hidden", owner: "me", hour: "00")
        hidden.visibility = "locked"
        var trashed = Row(id: "trashed", owner: "me", hour: "00")
        trashed.trashed = true
        for (query, ids, detailIDs) in examples {
            let transport = Transport(rows: Row.examples + [hidden, trashed])
            let api = GalleryTimeline(server: server, token: "token", send: transport.send)
            let rows = try await api.items(bucket, query: query)
            #expect(rows.map(\.id) == ids)
            #expect(Set(await transport.paths) == detailIDs.union(["bucket"]))
            if query.filter == .screenshots { #expect(rows.allSatisfy(\.isScreenshot)) }
            if query.filter == .edited { #expect(rows.allSatisfy(\.isEdited)) }
            if query.filter == .capturedByMe { #expect(rows.allSatisfy(\.hasCamera)) }
        }
    }

    @Test func contradictionsDoNotNeedAnyNetworkRequests() async throws {
        let transport = Transport(rows: [])
        let api = GalleryTimeline(server: server, token: "token", send: transport.send)
        for query in [query(.screenshots, screenshots: false), query(.sharedWithYou, shared: false)] {
            #expect(try await api.buckets(query).isEmpty)
            #expect(try await api.items(bucket, query: query).isEmpty)
        }
        #expect(await transport.paths.isEmpty)
    }

    @Test func malformedColumnsAndUnavailableMetadataAreErrorsNotEmptyMatches() async throws {
        for failure in [Transport.Failure.shortColumn, .missingEditFlag, .denied] {
            let transport = Transport(rows: Row.examples, failure: failure)
            let api = GalleryTimeline(server: server, token: "token", send: transport.send)
            do {
                _ = try await api.items(bucket, query: query(.edited))
                Issue.record("Expected a failure for \(failure)")
            } catch let error as CloudError {
                #expect(error.kind == (failure == .denied ? .http(status: 403) : .decoding))
            }
        }
    }
}

private struct Row: Sendable {
    let id, owner, hour: String
    var isImage = true, favourite = false, trashed = false
    var visibility = "timeline"
    var offset = 0.0
    var make: String?
    var name = "IMG_01.HEIC"
    var edited = false

    static let examples = [
        Row(id: "shot", owner: "me", hour: "14", offset: 5.5, name: "Screenshot 1.HEIC"),
        Row(id: "camera", owner: "partner", hour: "17", offset: -1, make: "Apple", name: "EXPORT.PNG", edited: true),
        Row(id: "video", owner: "me", hour: "20", isImage: false, favourite: true, make: "Sony"),
    ]
}

private actor Transport {
    enum Failure { case shortColumn, missingEditFlag, denied }
    let rows: [Row]
    let failure: Failure?
    private(set) var requests: [URLRequest] = []
    var paths: [String] { requests.compactMap { $0.url?.lastPathComponent } }

    init(rows: [Row], failure: Failure? = nil) {
        self.rows = rows
        self.failure = failure
    }

    func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        let url = try #require(request.url)
        var status = 200
        let body: Any
        switch url.path {
        case "/photos/api/timeline/buckets":
            body = [["timeBucket": "2025-01-01", "count": 3], ["timeBucket": "2025-02-01", "count": 1]]
        case "/photos/api/timeline/bucket":
            let columns: [String: Any] = [
                "id": rows.map(\.id), "ownerId": rows.map(\.owner), "visibility": rows.map(\.visibility),
                "isImage": rows.map(\.isImage), "isTrashed": rows.map(\.trashed), "isFavorite": rows.map(\.favourite),
                "ratio": rows.map { _ in 1.5 }, "thumbhash": rows.map { $0.id == "camera" ? "abc=" : nil },
                "livePhotoVideoId": rows.map { $0.id == "camera" ? "live-video" : nil },
                "duration": rows.map { $0.isImage ? nil : 2405 }, "localOffsetHours": rows.map(\.offset),
                "fileCreatedAt": rows.map { "2025-01-01T\($0.hour):00:00.000000" },
                "createdAt": failure == .shortColumn ? [] : rows.map { _ in "2025-01-02T12:00:00Z" },
            ]
            body = columns
        case _ where url.deletingLastPathComponent().path == "/photos/api/assets":
            let row = try #require(rows.first(where: { $0.id == url.lastPathComponent }))
            if failure == .denied { status = 403 }
            var detail: [String: Any] = ["id": row.id, "hasMetadata": true, "originalFileName": row.name,
                                         "visibility": row.visibility, "isTrashed": row.trashed, "isEdited": row.edited]
            if let make = row.make { detail["exifInfo"] = ["make": make] }
            if failure == .missingEditFlag { detail.removeValue(forKey: "isEdited") }
            body = detail
        default:
            Issue.record("Unexpected endpoint: \(url.path)")
            throw URLError(.unsupportedURL)
        }
        let response = try #require(HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil))
        return (try JSONSerialization.data(withJSONObject: body), response)
    }
}

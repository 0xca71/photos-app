import CloudCore
import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing
@testable import ImmichAPI

@Suite struct RandomSearchTransportTests {
    private func client(_ transport: RecordingTransport) -> Client {
        ImmichClient.make(server: URL(string: "https://nas.test")!, transport: transport) { "test-token" }
    }

    @Test func unfilteredRequestHasOnlySizeAndDecodesBareAssetArrayInOrder() async throws {
        let transport = RecordingTransport(response: mixedAssets)
        let assets = try await client(transport).randomItems(.init(), size: 25)
        try await transport.expectRequest(json: #"{"size":25}"#)

        #expect(assets.map(\.id) == ["8562403c-3440-4897-84c4-856cad32c952", "816fe8ca-0ed2-4d29-8f14-c3e7033874c3"])
        #expect(assets.map(\.isVideo) == [true, false])
        #expect(assets.map(\.durationMs) == [9_876, nil])
        let photo = try #require(assets.last)
        #expect(photo.originalFileName == "q2.png")
        #expect(photo.localDateTime == Date(timeIntervalSince1970: 1_597_489_200))
        #expect(photo.thumbhash == "thumbhash")
    }

    @Test func combinesAlbumMediaAndInclusiveMillisecondBounds() async throws {
        let transport = RecordingTransport(response: "[]")
        let query = CloudRandomQuery(
            albumID: "5ac18dbb-6531-4a45-bcd8-73dc19ef864a", isVideo: true,
            takenAfter: Date(timeIntervalSince1970: 1_700_000_000.125),
            takenBefore: Date(timeIntervalSince1970: 1_700_006_399.999)
        )
        let assets = try await client(transport).randomItems(query, size: 17)
        try await transport.expectRequest(json: #"""
        {"albumIds":["5ac18dbb-6531-4a45-bcd8-73dc19ef864a"],"type":"VIDEO","takenAfter":"2023-11-14T22:13:20.125Z","takenBefore":"2023-11-14T23:59:59.999Z","size":17}
        """#)
        #expect(assets.isEmpty)
    }

    @Test func photoOnlyDoesNotSendAlbumOrDateFilters() async throws {
        let transport = RecordingTransport(response: "[]")
        _ = try await client(transport).randomItems(.init(isVideo: false), size: 1)
        try await transport.expectRequest(json: #"{"type":"IMAGE","size":1}"#)
    }

    @Test func serverRejectionIsNotAnEmptyDraw() async throws {
        let transport = RecordingTransport(status: .unauthorized, response: #"{"message":"Token expired"}"#)
        do {
            _ = try await client(transport).randomItems(.init(), size: 5)
            Issue.record("Expected an authentication error")
        } catch let error as CloudError {
            #expect(error.kind == .unauthorized)
            #expect(error.message.contains("Token expired"))
        }
        try await transport.expectRequest(json: #"{"size":5}"#)
    }
}

/// Records the serialized request after production middleware and returns the fixture as HTTP bytes.
private actor RecordingTransport: ClientTransport {
    let status: HTTPResponse.Status
    let response: String
    private var calls: [(URL, HTTPRequest, Data)] = []

    init(status: HTTPResponse.Status = .ok, response: String) {
        self.status = status
        self.response = response
    }

    func send(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String) async throws -> (HTTPResponse, HTTPBody?) {
        let data = try await Data(collecting: #require(body), upTo: 4096)
        calls.append((baseURL, request, data))
        return (.init(status: status, headerFields: [.contentType: "application/json"]), HTTPBody(response))
    }

    func expectRequest(json: String) throws {
        #expect(calls.count == 1)
        let (baseURL, request, body) = try #require(calls.first)
        #expect(baseURL.absoluteString == "https://nas.test/api")
        #expect(request.path == "/search/random")
        #expect(request.method == .post)
        #expect(request.headerFields[.authorization] == "Bearer test-token")
        let fields = try #require(try JSONSerialization.jsonObject(with: body) as? NSDictionary)
        let expected = try #require(try JSONSerialization.jsonObject(with: Data(json.utf8)) as? NSDictionary)
        #expect(fields == expected)
    }
}

// Gallery's recorded cleanup_contract/100-details-asset-q2.json (asset fields), alongside a video.
private let mixedAssets = #"""
[
  {
    "id":"8562403c-3440-4897-84c4-856cad32c952","type":"VIDEO","duration":9876,"originalFileName":"clip.mov",
    "fileCreatedAt":"2023-08-01T10:00:00.000Z","fileModifiedAt":"2023-08-01T10:00:00.000Z","localDateTime":"2023-08-01T10:00:00.000Z",
    "createdAt":"2023-08-02T10:00:00.000Z","updatedAt":"2023-08-02T10:00:00.000Z","width":1920,"height":1080,
    "ownerId":"08b9a1e0-f911-48af-8535-98ed8e450e3b","checksum":"YWJjZA==","thumbhash":null,"originalPath":"clip.mov",
    "isArchived":false,"isEdited":false,"isFavorite":true,"isOffline":false,"isTrashed":false,"hasMetadata":true,"visibility":"timeline"
  },
  {
    "id":"816fe8ca-0ed2-4d29-8f14-c3e7033874c3","type":"IMAGE","duration":null,"originalFileName":"q2.png",
    "fileCreatedAt":"2020-08-15T11:00:00.000Z","fileModifiedAt":"2020-08-15T11:00:00.000Z","localDateTime":"2020-08-15T11:00:00.000Z",
    "createdAt":"2000-01-01T00:00:00.000Z","updatedAt":"2000-01-01T00:00:00.000Z","width":1,"height":1,
    "ownerId":"08b9a1e0-f911-48af-8535-98ed8e450e3b","checksum":"7V/icPiznwUMte5OqoZddyQUPyQ=","thumbhash":"thumbhash","originalPath":"originalPath",
    "isArchived":false,"isEdited":false,"isFavorite":false,"isOffline":false,"isTrashed":false,"hasMetadata":true,"visibility":"timeline"
  }
]
"""#

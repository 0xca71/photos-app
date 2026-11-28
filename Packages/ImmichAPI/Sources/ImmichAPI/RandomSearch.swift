import CloudCore
import Foundation

/// A small client for Immich's server-side random search endpoint.
///
/// The generated client is intentionally filtered to the operations used by the
/// rest of the app. Random search is kept here as a typed, provider-specific
/// request so the app can fetch NAS assets without syncing the whole library.
public struct ImmichRandomSearchClient: Sendable {
    private let server: URL
    private let token: String
    private let session: URLSession

    public init(server: URL, token: String, session: URLSession = ImmichClient.makeSession()) {
        self.server = server
        self.token = token
        self.session = session
    }

    public func search(_ query: CloudRandomSearchQuery, limit: Int) async throws -> [CloudAsset] {
        let body = RequestBody(query: query, size: min(max(limit, 1), 1000))
        var request = URLRequest(url: ImmichClient.apiURL(for: server).appending(path: "search/random"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        for (name, value) in DeviceHeaders.values {
            request.setValue(value, forHTTPHeaderField: name.rawName)
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(date.formatted(.iso8601.year().month().day().time(includingFractionalSeconds: true).timeZone(separator: .omitted)))
        }
        request.httpBody = try encoder.encode(body)

        do {
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw CloudError(kind: .transport, message: String(localized: "The server returned an invalid response."))
            }
            guard response.statusCode == 200 else {
                throw APIError.from(statusCode: response.statusCode, body: data, operation: "Random search")
            }
            let assets = try ImmichDateParser.makeJSONDecoder().decode([Components.Schemas.AssetResponseDto].self, from: data)
            return assets.map(CloudAsset.init)
        } catch let error as CloudError {
            throw error
        } catch {
            throw APIError.wrap(error, operation: "Random search")
        }
    }

    private struct RequestBody: Encodable {
        let albumIds: [String]?
        let takenAfter: Date?
        let takenBefore: Date?
        let type: String?
        let size: Int

        init(query: CloudRandomSearchQuery, size: Int) {
            albumIds = query.albumID.map { [$0] }
            takenAfter = query.takenAfter
            takenBefore = query.takenBefore
            type = query.mediaType?.rawValue
            self.size = size
        }
    }
}

import CloudCore
import ImmichAPI

extension ImmichConnection: CloudRandomSearchConnection {
    func randomSearch(_ query: CloudRandomSearchQuery, limit: Int) async throws -> [CloudAsset] {
        try await ImmichRandomSearchClient(server: server.url, token: token).search(query, limit: limit)
    }
}

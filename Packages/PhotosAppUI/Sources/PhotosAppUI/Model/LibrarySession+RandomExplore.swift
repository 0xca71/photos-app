import CloudCore
import Persistence

extension LibrarySession {
    /// Fetches assets for Random Explore directly from the server. The result is
    /// deliberately not written to the synced database because this screen is
    /// useful before the full NAS library has been indexed on the phone.
    func randomExploreItems(_ query: CloudRandomSearchQuery, limit: Int) async throws -> [TimelineItem] {
        let connection = try connected()
        guard let random = connection as? any CloudRandomSearchConnection else {
            throw CloudError(kind: .http(status: 404), message: String(localized: "This server does not support Random Explore."))
        }
        return try await random.randomSearch(query, limit: limit).map(TimelineItem.init)
    }
}

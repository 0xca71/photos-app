import Foundation

/// The media types accepted by the server-side random search endpoint.
public enum CloudRandomMediaType: String, Sendable, Hashable {
    case image = "IMAGE"
    case video = "VIDEO"
}

/// Filters for a server-side random asset request. Empty fields are omitted from the request.
public struct CloudRandomSearchQuery: Sendable, Hashable {
    public var albumID: String?
    public var takenAfter: Date?
    public var takenBefore: Date?
    public var mediaType: CloudRandomMediaType?

    public init(albumID: String? = nil, takenAfter: Date? = nil, takenBefore: Date? = nil, mediaType: CloudRandomMediaType? = nil) {
        self.albumID = albumID
        self.takenAfter = takenAfter
        self.takenBefore = takenBefore
        self.mediaType = mediaType
    }
}

/// An optional capability of a Cloud connection. Keeping this separate from
/// `CloudConnection` lets providers add random exploration without making every
/// existing test or provider implement an endpoint it does not support.
public protocol CloudRandomSearchConnection: Sendable {
    func randomSearch(_ query: CloudRandomSearchQuery, limit: Int) async throws -> [CloudAsset]
}

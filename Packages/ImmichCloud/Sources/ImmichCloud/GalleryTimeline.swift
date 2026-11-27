import CloudCore
import Foundation
import ImmichAPI
import Persistence

/// Gallery's internal timeline routes are not in the generated upstream client. Both calls
/// must compose the same personal timeline: `userId` selects whose timeline, `ownerId` narrows it.
struct GalleryTimeline: Sendable {
    let server: URL
    let token: String
    let send: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    func buckets(_ query: CloudTimelineQuery) async throws -> [CloudTimelineBucket] {
        guard !query.excludesEverything else { return [] }
        struct Summary: Decodable { let timeBucket: String; let count: Int }
        let summaries: [Summary] = try await get("timeline/buckets", options: query.options)
        // Gallery sorts these by the bucket date in SQL (including years outside 0001...9999).
        return try summaries.map {
            guard $0.count >= 0 else { throw invalidTimeline("Negative bucket count.") }
            return CloudTimelineBucket(timeBucket: $0.timeBucket, count: $0.count)
        }
    }

    func items(_ bucket: CloudTimelineBucket, query: CloudTimelineQuery) async throws -> [TimelineItem] {
        guard !query.excludesEverything else { return [] }
        var options = query.options
        options.append(.init(name: "timeBucket", value: bucket.timeBucket))
        let columns: BucketColumns = try await get("timeline/bucket", options: options)
        try columns.validate()

        // Preserve the server's order, including ties, regardless of detail completion order.
        var matches: [TimelineItem] = []
        if !query.requiresDetail {
            matches.reserveCapacity(columns.id.count)
            for i in columns.id.indices where columns.isCandidate(i, for: query) {
                matches.append(columns.item(i))
            }
        } else {
            // Only images can be screenshots. Hidden screenshots must not cause detail GETs for videos.
            var details: [Int: AssetDetail] = [:]
            try await withThrowingTaskGroup(of: (Int, AssetDetail).self) { group in
                var pending = 0
                for i in columns.id.indices where columns.isCandidate(i, for: query) && query.needsDetail(isImage: columns.isImage[i]) {
                    try Task.checkCancellation()
                    if pending == 4, let (index, detail) = try await group.next() {
                        details[index] = detail
                        pending -= 1
                    }
                    let id = columns.id[i]
                    group.addTask {
                        let detail: AssetDetail = try await get("assets/\(id)")
                        guard detail.id == id && detail.hasMetadata else { throw invalidTimeline("Asset metadata unavailable.") }
                        return (i, detail)
                    }
                    pending += 1
                }
                for try await (i, detail) in group { details[i] = detail }
            }
            for i in columns.id.indices where columns.isCandidate(i, for: query) {
                if query.needsDetail(isImage: columns.isImage[i]) {
                    guard let detail = details[i] else { throw invalidTimeline("Missing requested asset metadata.") }
                    guard detail.visibility == "timeline", !detail.isTrashed else { continue }
                    let item = columns.item(i, detail: detail)
                    if !query.showScreenshots && item.isScreenshot { continue }
                    if query.filter == .screenshots && !item.isScreenshot { continue }
                    if query.filter == .capturedByMe && !item.hasCamera { continue }
                    if query.filter == .edited && !item.isEdited { continue }
                    matches.append(item)
                } else {
                    matches.append(columns.item(i))
                }
            }
        }
        // Gallery's takenAt SQL sorts UTC instants within each local day. The native grid
        // uses wall-clock capture time; these differ when owners change time zones in a day.
        if !query.addedOrder { matches.sort { $0.date < $1.date } }
        return matches
    }

    private func get<T: Decodable>(_ path: String, options: [URLQueryItem] = []) async throws -> T {
        let url = ImmichClient.apiURL(for: server).appending(path: path).appending(queryItems: options)
        var request = MediaEndpoints.request(url, token: token)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            try Task.checkCancellation()
            let (data, response) = try await send(request)
            guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
            guard http.statusCode == 200 else {
                throw APIError.from(statusCode: http.statusCode, body: data, operation: "browse the timeline")
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            try Task.checkCancellation()
            throw CloudError.wrap(error, operation: "Browse the timeline")
        }
    }
}

private extension CloudTimelineQuery {
    var excludesEverything: Bool {
        (!showScreenshots && filter == .screenshots) || (!showShared && filter == .sharedWithYou)
    }

    var options: [URLQueryItem] {
        var items: [URLQueryItem] = [
            .init(name: "userId", value: userID), .init(name: "visibility", value: "timeline"),
            .init(name: "withStacked", value: "true"), .init(name: "order", value: "asc"),
            .init(name: "orderBy", value: addedOrder ? "createdAt" : "takenAt"), .init(name: "bucketSize", value: "month"),
        ]
        if showShared && filter != .favourites {
            items.append(.init(name: "withPartners", value: "true"))
            items.append(.init(name: "withSharedSpaces", value: "true"))
        }
        if !showShared || filter == .capturedByMe { items.append(.init(name: "ownerId", value: userID)) }
        switch filter {
        case .favourites: items.append(.init(name: "isFavorite", value: "true"))
        case .notInAlbum: items.append(.init(name: "isNotInAlbum", value: "true"))
        case .photos, .screenshots: items.append(.init(name: "type", value: "IMAGE"))
        case .videos: items.append(.init(name: "type", value: "VIDEO"))
        default: break
        }
        return items
    }

    var requiresDetail: Bool { needsDetail(isImage: filter != .videos) }

    func needsDetail(isImage: Bool) -> Bool {
        filter == .edited || filter == .capturedByMe || filter == .screenshots || (!showScreenshots && isImage)
    }
}

/// Decode only the detail fields involved in classification, not faces, GPS, tags, etc.
private struct AssetDetail: Decodable, Sendable {
    struct Exif: Decodable { let make: String? }
    let id: String
    let hasMetadata, isEdited, isTrashed: Bool
    let visibility, originalFileName: String
    let exifInfo: Exif?
    var hasCamera: Bool { !(exifInfo?.make?.isEmpty ?? true) }
    func isScreenshot(isImage: Bool) -> Bool {
        guard isImage, !hasCamera else { return false }
        let name = originalFileName.lowercased()
        return name.hasSuffix(".png") || name.contains("screenshot")
    }
}

/// `to_json(agg)` serializes the SQL `AT TIME ZONE 'UTC'` timestamps without a zone suffix.
private struct BucketTimestamp: Decodable {
    let date: Date
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        // Accept both the repository's naive UTC timestamps and the DTO's ISO-8601 representation.
        let timestamp = value.last?.isNumber == true && !value.dropFirst(10).contains(where: { $0 == "+" || $0 == "-" })
            ? value + "Z" : value
        guard let date = ImmichDateParser.parse(timestamp) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid bucket timestamp: \(value)")
        }
        self.date = date
    }
}

/// The bucket is one object of parallel arrays, not an array of asset DTOs. Nullable *elements*
/// (e.g. duration for an image) must not shift the other columns out of alignment.
private struct BucketColumns: Decodable {
    let id, ownerId, visibility: [String]
    let isImage, isTrashed, isFavorite: [Bool]
    let ratio, localOffsetHours: [Double]
    let thumbhash, livePhotoVideoId: [String?]
    let duration: [Int?]
    let createdAt, fileCreatedAt: [BucketTimestamp]

    func validate() throws {
        let count = id.count
        guard ownerId.count == count, visibility.count == count, isImage.count == count,
              isTrashed.count == count, isFavorite.count == count, ratio.count == count,
              thumbhash.count == count, livePhotoVideoId.count == count, duration.count == count,
              createdAt.count == count, fileCreatedAt.count == count, localOffsetHours.count == count else {
            throw invalidTimeline("Timeline bucket columns have different lengths.")
        }
    }

    func isCandidate(_ i: Int, for query: CloudTimelineQuery) -> Bool {
        guard visibility[i] == "timeline", !isTrashed[i] else { return false }
        let mine = ownerId[i] == query.userID
        if !query.showShared && !mine { return false }
        switch query.filter {
        case .sharedWithYou: return !mine
        case .capturedByMe: return mine
        case .favourites: return mine && isFavorite[i]
        case .photos, .screenshots: return isImage[i]
        case .videos: return !isImage[i]
        default: return true
        }
    }

    func item(_ i: Int, detail: AssetDetail? = nil) -> TimelineItem {
        TimelineItem(
            id: id[i], date: fileCreatedAt[i].date.addingTimeInterval(localOffsetHours[i] * 3600),
            isVideo: !isImage[i], durationMs: duration[i], isFavorite: isFavorite[i],
            isLivePhoto: livePhotoVideoId[i] != nil, thumbhash: thumbhash[i], aspectRatio: ratio[i],
            uploadedAt: createdAt[i].date, isEdited: detail?.isEdited ?? false, hasCamera: detail?.hasCamera ?? false,
            isScreenshot: detail?.isScreenshot(isImage: isImage[i]) ?? false, ownerID: ownerId[i]
        )
    }
}

private func invalidTimeline(_ reason: String) -> CloudError {
    CloudError(kind: .decoding, message: "Could not read the server timeline: \(reason)")
}

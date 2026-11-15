import CoreImage
import CoreML
import CoreVideo
import Foundation

/// How near each part of a photo is, estimated on the iPhone by a small depth model
/// (Depth Anything V2 Small, built into the app). Nothing leaves the phone.
struct DepthMap: Sendable {
    let width: Int
    let height: Int
    /// Row by row from the top; 0 = farthest, 1 = nearest.
    let values: [Float]
    /// How much real depth the scene has (0 = flat, like a wall or a document; 1 = deep).
    let relief: Float
}

enum SpatialError: LocalizedError {
    case modelMissing, noImage, modelFailed(String), renderFailed

    var errorDescription: String? {
        switch self {
        case .modelMissing: String(localized: "This build doesn't include the depth model.")
        case .noImage: String(localized: "The photo hasn't loaded yet.")
        case .modelFailed(let reason): String(localized: "The depth of this photo couldn't be worked out. \(reason)")
        case .renderFailed: String(localized: "The spatial scene couldn't be drawn on this iPhone.")
        }
    }
}

actor DepthEstimator {
    static let shared = DepthEstimator()
    static let modelName = "DepthAnythingV2SmallF16"
    /// The model's fixed input size.
    static let inputWidth = 518, inputHeight = 392

    /// Whether this build carries the model (the Spatial Scene button hides without it).
    nonisolated static var isAvailable: Bool { modelURL != nil }
    nonisolated static var modelURL: URL? { Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") }

    private var model: MLModel?
    private let context = CIContext(options: [.cacheIntermediates: false])
    /// Seconds the model took to load, and the last estimate took (for diagnostics).
    private(set) var loadSeconds = 0.0
    private(set) var lastSeconds = 0.0

    /// Loads the model. It runs on the CPU: measured on an iPhone 12 Pro Max, that loads in
    /// 0.3 s and estimates in 0.09 s, where the Neural Engine takes almost 7 s to load each time
    /// (for 0.03 s estimates), and a photo needs only one estimate.
    func prepare(computeUnits: MLComputeUnits = .cpuOnly) throws {
        guard model == nil else { return }
        guard let url = Self.modelURL else { throw SpatialError.modelMissing }
        let configuration = MLModelConfiguration()
        configuration.computeUnits = computeUnits
        let started = Date()
        do {
            model = try MLModel(contentsOf: url, configuration: configuration)
        } catch {
            throw SpatialError.modelFailed(error.localizedDescription)
        }
        loadSeconds = Date().timeIntervalSince(started)
    }

    /// Frees the model's memory (the viewer closed).
    func unload() {
        model = nil
    }

    /// Estimates depth for an upright image. The image is squeezed to the model's shape;
    /// the map comes back in that shape and is stretched over the photo by the caller.
    func depth(of image: CGImage) throws -> DepthMap {
        try prepare()
        guard let model else { throw SpatialError.modelMissing }
        let started = Date()
        let width = Self.inputWidth, height = Self.inputHeight
        var buffer: CVPixelBuffer?
        let attributes = [kCVPixelBufferIOSurfacePropertiesKey: [:], kCVPixelBufferMetalCompatibilityKey: true] as CFDictionary
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attributes, &buffer)
        guard let buffer else { throw SpatialError.modelFailed("") }
        let source = CIImage(cgImage: image)
        let scaled = source.transformed(by: CGAffineTransform(scaleX: CGFloat(width) / source.extent.width, y: CGFloat(height) / source.extent.height))
        context.render(scaled, to: buffer, bounds: CGRect(x: 0, y: 0, width: width, height: height), colorSpace: CGColorSpace(name: CGColorSpace.sRGB))

        let output: MLFeatureProvider
        do {
            let input = try MLDictionaryFeatureProvider(dictionary: ["image": MLFeatureValue(pixelBuffer: buffer)])
            output = try model.prediction(from: input)
        } catch {
            throw SpatialError.modelFailed(error.localizedDescription)
        }
        guard let depth = output.featureValue(for: "depth")?.imageBufferValue else { throw SpatialError.modelFailed("") }
        let map = try Self.normalised(depth)
        lastSeconds = Date().timeIntervalSince(started)
        return map
    }

    /// The model gives relative inverse depth (bigger = nearer) on an arbitrary scale.
    /// It's stretched between its 2nd and 98th percentiles so stray extremes don't flatten the rest.
    private static func normalised(_ buffer: CVPixelBuffer) throws -> DepthMap {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        let width = CVPixelBufferGetWidth(buffer), height = CVPixelBufferGetHeight(buffer)
        guard let base = CVPixelBufferGetBaseAddress(buffer), width > 0, height > 0 else { throw SpatialError.modelFailed("") }
        let rowBytes = CVPixelBufferGetBytesPerRow(buffer)
        let format = CVPixelBufferGetPixelFormatType(buffer)
        var raw = [Float](repeating: 0, count: width * height)
        for y in 0..<height {
            let row = base + y * rowBytes
            switch format {
            case kCVPixelFormatType_OneComponent16Half, kCVPixelFormatType_DepthFloat16, kCVPixelFormatType_DisparityFloat16:
                let values = row.assumingMemoryBound(to: Float16.self)
                for x in 0..<width { raw[y * width + x] = Float(values[x]) }
            case kCVPixelFormatType_OneComponent32Float, kCVPixelFormatType_DepthFloat32, kCVPixelFormatType_DisparityFloat32:
                let values = row.assumingMemoryBound(to: Float.self)
                for x in 0..<width { raw[y * width + x] = values[x] }
            case kCVPixelFormatType_OneComponent8:
                let values = row.assumingMemoryBound(to: UInt8.self)
                for x in 0..<width { raw[y * width + x] = Float(values[x]) / 255 }
            default:
                throw SpatialError.modelFailed("")
            }
        }
        var sample: [Float] = []
        sample.reserveCapacity(raw.count / 4 + 1)
        for index in stride(from: 0, to: raw.count, by: 4) where raw[index].isFinite { sample.append(raw[index]) }
        guard sample.count > 16 else { throw SpatialError.modelFailed("") }
        sample.sort()
        let low = sample[Int(Float(sample.count - 1) * 0.02)], high = sample[Int(Float(sample.count - 1) * 0.98)]
        let range = high - low
        guard range > 1e-6 else {
            return DepthMap(width: width, height: height, values: [Float](repeating: 0.5, count: raw.count), relief: 0)
        }
        for index in raw.indices {
            let value = raw[index].isFinite ? raw[index] : low
            raw[index] = min(max((value - low) / range, 0), 1)
        }
        // Inverse depth that barely changes relative to its size means a nearly flat scene.
        let relief = min(max(range / max(abs(high), 1e-6), 0), 1)
        return DepthMap(width: width, height: height, values: raw, relief: relief)
    }
}

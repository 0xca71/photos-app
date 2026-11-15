import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

/// Everything the renderer needs to show a photo with depth. Built once per photo.
/// - `color`: the photo (Display P3, 8-bit RGBA).
/// - `depth`: how near each point is (0 far … 1 near), sharpened along the photo's edges.
/// - `backColor` / `backDepth`: the scene with nearer things removed and the gaps filled from
///   what's around them. It shows in the slivers that open up behind things as the view moves.
struct SpatialScene: Sendable {
    let width: Int, height: Int
    let color: Data
    let auxWidth: Int, auxHeight: Int
    let depth: Data
    let backDepth: Data
    let backColor: Data
    /// The depth that stays still as the view moves (nearer things go one way, farther the other).
    let focus: Float
    /// 0…1: flat scenes move less, so estimation noise isn't blown up into wobble.
    let strength: Float

    var memoryBytes: Int { color.count + depth.count + backDepth.count + backColor.count }
}

enum SpatialSceneBuilder {
    /// Longest side of the photo texture, and of the depth and background layers.
    static let colorSide: CGFloat = 2048, auxSide: CGFloat = 768

    /// Builds the scene from an upright image and its depth map. Core Image does the work on the GPU.
    static func build(image: CGImage, depth: DepthMap) throws -> SpatialScene {
        let source = CIImage(cgImage: image)
        let longest = max(source.extent.width, source.extent.height)
        guard longest > 0 else { throw SpatialError.noImage }

        // The photo, in Display P3.
        let colorScale = min(1, colorSide / longest)
        let width = max(Int((source.extent.width * colorScale).rounded()), 2), height = max(Int((source.extent.height * colorScale).rounded()), 2)
        let managed = CIContext(options: [.cacheIntermediates: false])
        let fitted = source.transformed(by: CGAffineTransform(scaleX: CGFloat(width) / source.extent.width, y: CGFloat(height) / source.extent.height))
        guard let p3 = CGColorSpace(name: CGColorSpace.displayP3) else { throw SpatialError.renderFailed }
        var color = Data(count: width * height * 4)
        color.withUnsafeMutableBytes { bytes in
            managed.render(fitted, toBitmap: bytes.baseAddress!, rowBytes: width * 4, bounds: CGRect(x: 0, y: 0, width: width, height: height), format: .RGBA8, colorSpace: p3)
        }

        // From here on the images are plain numbers: no colour management.
        let data = CIContext(options: [.workingColorSpace: NSNull(), .outputColorSpace: NSNull(), .cacheIntermediates: false])
        let auxScale = min(1, auxSide / CGFloat(max(width, height)))
        let auxWidth = max(Int((CGFloat(width) * auxScale).rounded()), 2), auxHeight = max(Int((CGFloat(height) * auxScale).rounded()), 2)
        let aux = CGRect(x: 0, y: 0, width: auxWidth, height: auxHeight)
        let colorImage = CIImage(bitmapData: color, bytesPerRow: width * 4, size: CGSize(width: width, height: height), format: .RGBA8, colorSpace: nil)
        let guide = colorImage
            .transformed(by: CGAffineTransform(scaleX: CGFloat(auxWidth) / CGFloat(width), y: CGFloat(auxHeight) / CGFloat(height)))
            .cropped(to: aux)

        // The depth map as a grey image, stretched over the photo and sharpened along the photo's edges.
        var grey = Data(count: depth.width * depth.height * 4)
        grey.withUnsafeMutableBytes { raw in
            let bytes = raw.bindMemory(to: UInt8.self)
            for index in 0..<(depth.width * depth.height) {
                let value = UInt8(max(0, min(255, (depth.values[index] * 255).rounded())))
                bytes[index * 4] = value; bytes[index * 4 + 1] = value; bytes[index * 4 + 2] = value; bytes[index * 4 + 3] = 255
            }
        }
        let small = CIImage(bitmapData: grey, bytesPerRow: depth.width * 4, size: CGSize(width: depth.width, height: depth.height), format: .RGBA8, colorSpace: nil)
            .clampedToExtent()
            .transformed(by: CGAffineTransform(scaleX: CGFloat(auxWidth) / 2 / CGFloat(depth.width), y: CGFloat(auxHeight) / 2 / CGFloat(depth.height)))
            .cropped(to: CGRect(x: 0, y: 0, width: auxWidth / 2, height: auxHeight / 2))
        let upsample = CIFilter.edgePreserveUpsample()
        upsample.inputImage = guide
        upsample.smallImage = small
        upsample.spatialSigma = 3
        upsample.lumaSigma = 0.12
        let stretched = small.transformed(by: CGAffineTransform(scaleX: CGFloat(auxWidth) / small.extent.width, y: CGFloat(auxHeight) / small.extent.height))
        var near = (upsample.outputImage ?? stretched).cropped(to: aux)
        // Grown by a pixel or two, so a thing's outline moves with it and not with what's behind.
        near = morphology(near.clampedToExtent(), radius: 1.5, maximum: true).applyingGaussianBlur(sigma: 0.7).cropped(to: aux)
        near = near.settingAlphaOne(in: aux)

        // What lies behind: each point takes the farthest depth around it, smoothed.
        let reach = Float(max(auxWidth, auxHeight)) * 0.045
        let back = morphology(near.clampedToExtent(), radius: reach, maximum: false)
            .applyingGaussianBlur(sigma: Double(reach) * 0.6)
            .cropped(to: aux).settingAlphaOne(in: aux)

        // Nearer things (those standing out from what's behind them), as a mask.
        let difference = CIFilter.differenceBlendMode()
        difference.inputImage = near
        difference.backgroundImage = back
        let low: CGFloat = 0.07, high: CGFloat = 0.16, gain = 1 / (high - low)
        let ramp = CIFilter.colorMatrix()
        ramp.inputImage = (difference.outputImage ?? near).settingAlphaOne(in: aux)
        ramp.rVector = CIVector(x: gain, y: 0, z: 0, w: 0)
        ramp.gVector = CIVector(x: 0, y: gain, z: 0, w: 0)
        ramp.bVector = CIVector(x: 0, y: 0, z: gain, w: 0)
        ramp.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        ramp.biasVector = CIVector(x: -low * gain, y: -low * gain, z: -low * gain, w: 0)
        let clamp = CIFilter.colorClamp()
        clamp.inputImage = ramp.outputImage
        clamp.minComponents = CIVector(x: 0, y: 0, z: 0, w: 1)
        clamp.maxComponents = CIVector(x: 1, y: 1, z: 1, w: 1)
        let mask = (clamp.outputImage ?? near).cropped(to: aux)

        // The photo with the nearer things cut out, then filled in from around them:
        // blurring a cut-out image spreads only what remains, so each blur is a fill at one scale.
        let cut = CIFilter.blendWithMask()
        cut.inputImage = CIImage(color: .clear).cropped(to: aux)
        cut.backgroundImage = guide.settingAlphaOne(in: aux)
        cut.maskImage = mask
        let remaining = (cut.outputImage ?? guide).cropped(to: aux)
        var filled = remaining
        for radius in [3.0, 9.0, 27.0, 80.0] {
            var level = remaining.clampedToExtent().applyingGaussianBlur(sigma: radius).cropped(to: aux)
            // Laying a see-through fill over itself makes it solid without changing its colour.
            for _ in 0..<4 { level = level.composited(over: level) }
            filled = filled.composited(over: level)
        }
        filled = filled.composited(over: CIImage(color: CIColor(red: 0.5, green: 0.5, blue: 0.5)).cropped(to: aux)).settingAlphaOne(in: aux)

        func render(_ image: CIImage, format: CIFormat, bytesPerPixel: Int) -> Data {
            var output = Data(count: auxWidth * auxHeight * bytesPerPixel)
            output.withUnsafeMutableBytes { bytes in
                data.render(image, toBitmap: bytes.baseAddress!, rowBytes: auxWidth * bytesPerPixel, bounds: aux, format: format, colorSpace: nil)
            }
            return output
        }
        let scene = SpatialScene(
            width: width, height: height, color: color, auxWidth: auxWidth, auxHeight: auxHeight,
            depth: render(near, format: .R8, bytesPerPixel: 1),
            backDepth: render(back, format: .R8, bytesPerPixel: 1),
            backColor: render(filled, format: .RGBA8, bytesPerPixel: 4),
            focus: focus(of: depth),
            strength: 0.3 + 0.7 * smoothstep(0.08, 0.45, depth.relief)
        )
        return scene
    }

    private static func morphology(_ image: CIImage, radius: Float, maximum: Bool) -> CIImage {
        if maximum {
            let filter = CIFilter.morphologyMaximum()
            filter.inputImage = image
            filter.radius = radius
            return filter.outputImage ?? image
        }
        let filter = CIFilter.morphologyMinimum()
        filter.inputImage = image
        filter.radius = radius
        return filter.outputImage ?? image
    }

    /// The typical depth of the middle of the photo, where the subject usually is.
    private static func focus(of depth: DepthMap) -> Float {
        var middle: [Float] = []
        for y in stride(from: depth.height * 3 / 10, to: depth.height * 7 / 10, by: 3) {
            for x in stride(from: depth.width * 3 / 10, to: depth.width * 7 / 10, by: 3) {
                middle.append(depth.values[y * depth.width + x])
            }
        }
        guard !middle.isEmpty else { return 0.5 }
        middle.sort()
        return min(max(middle[middle.count / 2], 0.25), 0.75)
    }

    static func smoothstep(_ low: Float, _ high: Float, _ value: Float) -> Float {
        let t = min(max((value - low) / (high - low), 0), 1)
        return t * t * (3 - 2 * t)
    }
}

/// Recent scenes, so going back to a photo (or turning the effect off and on) is instant.
/// Kept in memory only: nothing about a photo's depth is written to disk.
@MainActor
enum SpatialSceneCache {
    private static var scenes: [(key: String, scene: SpatialScene)] = []
    private static let limit = 3

    static func scene(for key: String) -> SpatialScene? {
        scenes.first { $0.key == key }?.scene
    }

    static func store(_ scene: SpatialScene, for key: String) {
        scenes.removeAll { $0.key == key }
        scenes.append((key, scene))
        if scenes.count > limit { scenes.removeFirst(scenes.count - limit) }
    }

    static func removeAll() {
        scenes.removeAll()
    }
}

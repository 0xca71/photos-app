import CoreGraphics
import ImageIO
import UIKit
import UniformTypeIdentifiers
import simd

/// Development aid: `-SpatialSelfTest`. Opens the newest Library photo in the viewer and checks
/// the spatial scene end to end: how long the depth model takes, the layers it builds, frames
/// drawn from several viewpoints (saved to Library/Caches/selftest), then the real button.
/// "SHOT name" lines mark moments worth a screenshot of the phone. Nothing is changed or uploaded.
@MainActor
enum SpatialSelfTest {
    static var isEnabled: Bool { ProcessInfo.processInfo.arguments.contains("-SpatialSelfTest") }

    static func say(_ text: String) { ScreenCapture.log("SPATIALTEST " + text) }

    static func run(viewer: ViewerViewController) async {
        say("model in this build: \(DepthEstimator.isAvailable)")
        guard DepthEstimator.isAvailable else { return say("done") }
        var waited = 0
        // Wait for the full preview, not the small placeholder.
        while (viewer.spatialTestPage?.zoomView.imageView.image).map({ $0.size.width * $0.scale < 600 }) ?? true, waited < 150 {
            try? await Task.sleep(for: .milliseconds(100))
            waited += 1
        }
        guard let page = viewer.spatialTestPage, let image = page.zoomView.imageView.image else { say("no photo on screen"); return say("done") }
        say("photo \(Int(image.size.width * image.scale))×\(Int(image.size.height * image.scale)), badge \(viewer.spatialTestBadge.mode), badge frame \(viewer.spatialTestBadge.frame.integral), alpha \(viewer.spatialTestBadge.alpha)")
        try? await Task.sleep(for: .seconds(2))
        say("SHOT off")
        try? await Task.sleep(for: .seconds(5))

        // The pipeline on its own, timed.
        do {
            guard let upright = SpatialSceneFactory.upright(image) else { throw SpatialError.noImage }
            var started = Date()
            let depth = try await DepthEstimator.shared.depth(of: upright)
            let first = Date().timeIntervalSince(started)
            let load = await DepthEstimator.shared.loadSeconds
            started = Date()
            _ = try await DepthEstimator.shared.depth(of: upright)
            let second = Date().timeIntervalSince(started)
            say(String(format: "depth: model load %.2f s, first estimate %.2f s (with load), next %.3f s, map %d×%d, relief %.2f", load, first, second, depth.width, depth.height, depth.relief))
            started = Date()
            let scene = try SpatialSceneBuilder.build(image: upright, depth: depth)
            say(String(format: "scene: built in %.2f s, photo %d×%d, layers %d×%d, focus %.2f, strength %.2f, %.1f MB", Date().timeIntervalSince(started), scene.width, scene.height, scene.auxWidth, scene.auxHeight, scene.focus, scene.strength, Double(scene.memoryBytes) / 1_048_576))
            save(grey: scene.depth, width: scene.auxWidth, height: scene.auxHeight, name: "depth")
            save(grey: scene.backDepth, width: scene.auxWidth, height: scene.auxHeight, name: "back-depth")
            save(rgba: scene.backColor, width: scene.auxWidth, height: scene.auxHeight, name: "back-color")
            guard let renderer = SpatialRenderer.shared, let textures = renderer.textures(for: scene) else { throw SpatialError.renderFailed }
            let width = scene.width / 2, height = scene.height / 2
            guard let flat = renderer.image(textures, look: .zero, zoom: 1, width: scene.width, height: scene.height) else { throw SpatialError.renderFailed }
            say(String(format: "straight on at zoom 1 differs from the photo by %.4f (0 = identical)", difference(flat, upright)))
            var frames: [String: CGImage] = [:]
            for (name, look) in [("centre", SIMD2<Float>(0, 0)), ("left", SIMD2<Float>(-1, 0)), ("right", SIMD2<Float>(1, 0)), ("up", SIMD2<Float>(0, -1)), ("down", SIMD2<Float>(0, 1))] {
                started = Date()
                guard let frame = renderer.image(textures, look: look, zoom: SpatialRenderer.activeZoom, width: width, height: height) else { continue }
                frames[name] = frame
                save(frame, name: "view-\(name)")
                say(String(format: "view %@: drawn in %.0f ms", name, Date().timeIntervalSince(started) * 1000))
            }
            if let left = frames["left"], let right = frames["right"], let centre = frames["centre"], let up = frames["up"], let down = frames["down"] {
                say(String(format: "left vs right differ by %.4f, up vs down %.4f, centre vs left %.4f (parallax shows as > 0)", difference(left, right), difference(up, down), difference(centre, left)))
            }
        } catch {
            say("pipeline failed: \(error)")
        }
        // The label shown while a scene is made (it normally passes in a fraction of a second).
        viewer.spatialTestBadge.set(.generating, animated: false)
        viewer.view.layoutIfNeeded()
        try? await Task.sleep(for: .milliseconds(600))
        say("SHOT label")
        try? await Task.sleep(for: .seconds(4))
        viewer.spatialTestBadge.set(.off, animated: false)
        // Start the button from cold, as a first use would.
        await DepthEstimator.shared.unload()

        // The real button.
        viewer.spatialTestTap()
        say("tapped: badge \(viewer.spatialTestBadge.mode)")
        try? await Task.sleep(for: .milliseconds(450))
        say("SHOT generating")
        waited = 0
        while viewer.spatialTestBadge.mode != .on, waited < 300 {
            try? await Task.sleep(for: .milliseconds(100))
            waited += 1
        }
        say("badge \(viewer.spatialTestBadge.mode) after \(waited * 100) ms, scene view \(page.spatialSceneView != nil), badge frame \(viewer.spatialTestBadge.frame.integral)")
        try? await Task.sleep(for: .seconds(2))
        if let view = page.spatialSceneView {
            for (name, look) in [("on-centre", SIMD2<Float>(0, 0)), ("on-left", SIMD2<Float>(-1, 0)), ("on-right", SIMD2<Float>(1, 0))] {
                view.manualLook = look
                try? await Task.sleep(for: .milliseconds(900))
                say("SHOT \(name)")
                try? await Task.sleep(for: .seconds(5))
            }
            say(String(format: "drawing: GPU %.1f ms a frame, scale %.0f×, size %d×%d", view.averageGPUTime * 1000, view.contentScaleFactor, Int(view.drawableSize.width), Int(view.drawableSize.height)))
            view.manualLook = nil
        }
        viewer.spatialTestTap()
        try? await Task.sleep(for: .seconds(1))
        say("off again: badge \(viewer.spatialTestBadge.mode), scene view \(page.spatialSceneView != nil)")
        say("SHOT off-again")
        try? await Task.sleep(for: .seconds(4))
        say("done")
    }

    /// Mean absolute difference (0…1) between two images at a small common size.
    private static func difference(_ a: CGImage, _ b: CGImage) -> Double {
        func small(_ image: CGImage) -> [UInt8] {
            var pixels = [UInt8](repeating: 0, count: 96 * 96 * 4)
            if let context = CGContext(data: &pixels, width: 96, height: 96, bitsPerComponent: 8, bytesPerRow: 96 * 4,
                                       space: CGColorSpace(name: CGColorSpace.displayP3)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) {
                context.draw(image, in: CGRect(x: 0, y: 0, width: 96, height: 96))
            }
            return pixels
        }
        let pa = small(a), pb = small(b)
        var sum = 0
        for index in 0..<(96 * 96) { for channel in 0..<3 { sum += abs(Int(pa[index * 4 + channel]) - Int(pb[index * 4 + channel])) } }
        return Double(sum) / Double(96 * 96 * 3 * 255)
    }

    private static func save(_ image: CGImage, name: String) {
        guard let destination = CGImageDestinationCreateWithURL(ScreenCapture.folder.appending(path: "spatial-\(name).jpg") as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else { return }
        CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary)
        CGImageDestinationFinalize(destination)
    }

    private static func save(grey: Data, width: Int, height: Int, name: String) {
        guard let provider = CGDataProvider(data: grey as CFData),
              let image = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: width, space: CGColorSpaceCreateDeviceGray(),
                                  bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue), provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else { return }
        save(image, name: name)
    }

    private static func save(rgba: Data, width: Int, height: Int, name: String) {
        guard let provider = CGDataProvider(data: rgba as CFData), let space = CGColorSpace(name: CGColorSpace.displayP3),
              let image = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4, space: space,
                                  bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue), provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else { return }
        save(image, name: name)
    }
}

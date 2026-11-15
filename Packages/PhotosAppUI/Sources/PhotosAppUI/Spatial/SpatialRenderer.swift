import Core
import CoreGraphics
import Foundation
import Metal
import simd

/// Draws a `SpatialScene` from a slightly moved viewpoint.
///
/// For every pixel it walks a ray from near to far through the depth map and takes the first
/// surface it meets, so nearer things correctly cover farther ones. Where the view opens a gap
/// behind something (one texel stretched over many pixels), it shows the filled-in background
/// layer instead of a smear of the thing's edge.
@MainActor
final class SpatialRenderer {
    static let shared = SpatialRenderer()

    struct Textures {
        let color: MTLTexture, depth: MTLTexture, backColor: MTLTexture, backDepth: MTLTexture
        let size: SIMD2<Float>, auxSize: SIMD2<Float>
        let focus: Float, strength: Float
    }

    private struct Uniforms {
        var offset: SIMD2<Float>
        var focus: Float
        var zoom: Float
        var texel: SIMD2<Float>
        var padding: SIMD2<Float> = .zero
    }

    /// How far the nearest and farthest points move at full tilt, as a share of the photo's shorter side.
    static let amplitude: Float = 0.035
    /// Zoomed in just enough that the photo's edges never come into view.
    static let activeZoom: Float = 1.06
    static let pixelFormat = MTLPixelFormat.bgra8Unorm

    let device: MTLDevice
    private let queue: MTLCommandQueue
    private let pipeline: MTLRenderPipelineState

    private init?() {
        guard let device = MTLCreateSystemDefaultDevice(), let queue = device.makeCommandQueue() else { return nil }
        do {
            let library = try device.makeLibrary(source: Self.shader, options: nil)
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = library.makeFunction(name: "spatial_vertex")
            descriptor.fragmentFunction = library.makeFunction(name: "spatial_fragment")
            descriptor.colorAttachments[0].pixelFormat = Self.pixelFormat
            pipeline = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            Log.ui.error("Spatial scene shader: \(error.localizedDescription, privacy: .public)")
            return nil
        }
        self.device = device
        self.queue = queue
    }

    func textures(for scene: SpatialScene) -> Textures? {
        func texture(_ data: Data, width: Int, height: Int, format: MTLPixelFormat, bytesPerPixel: Int, mipmapped: Bool) -> MTLTexture? {
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: format, width: width, height: height, mipmapped: mipmapped)
            descriptor.usage = .shaderRead
            guard data.count >= width * height * bytesPerPixel, let texture = device.makeTexture(descriptor: descriptor) else { return nil }
            data.withUnsafeBytes { bytes in
                texture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: bytes.baseAddress!, bytesPerRow: width * bytesPerPixel)
            }
            return texture
        }
        guard let color = texture(scene.color, width: scene.width, height: scene.height, format: .rgba8Unorm, bytesPerPixel: 4, mipmapped: true),
              let depth = texture(scene.depth, width: scene.auxWidth, height: scene.auxHeight, format: .r8Unorm, bytesPerPixel: 1, mipmapped: false),
              let backDepth = texture(scene.backDepth, width: scene.auxWidth, height: scene.auxHeight, format: .r8Unorm, bytesPerPixel: 1, mipmapped: false),
              let backColor = texture(scene.backColor, width: scene.auxWidth, height: scene.auxHeight, format: .rgba8Unorm, bytesPerPixel: 4, mipmapped: false)
        else { return nil }
        // Smaller copies of the photo, so it stays smooth when shown below its full size.
        if let buffer = queue.makeCommandBuffer(), let blit = buffer.makeBlitCommandEncoder() {
            blit.generateMipmaps(for: color)
            blit.endEncoding()
            buffer.commit()
        }
        return Textures(
            color: color, depth: depth, backColor: backColor, backDepth: backDepth,
            size: SIMD2(Float(scene.width), Float(scene.height)), auxSize: SIMD2(Float(scene.auxWidth), Float(scene.auxHeight)),
            focus: scene.focus, strength: scene.strength
        )
    }

    func makeCommandBuffer() -> MTLCommandBuffer? { queue.makeCommandBuffer() }

    /// `look`: where the viewer is relative to straight on, -1…1 each way.
    func encode(_ textures: Textures, look: SIMD2<Float>, zoom: Float, pass: MTLRenderPassDescriptor, into buffer: MTLCommandBuffer) {
        guard let encoder = buffer.makeRenderCommandEncoder(descriptor: pass) else { return }
        let shift = Self.amplitude * textures.strength * min(textures.size.x, textures.size.y)
        var uniforms = Uniforms(
            offset: SIMD2(look.x * shift / textures.size.x, look.y * shift / textures.size.y),
            focus: textures.focus, zoom: zoom, texel: SIMD2(1 / textures.auxSize.x, 1 / textures.auxSize.y)
        )
        encoder.setRenderPipelineState(pipeline)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 0)
        encoder.setFragmentTexture(textures.color, index: 0)
        encoder.setFragmentTexture(textures.depth, index: 1)
        encoder.setFragmentTexture(textures.backColor, index: 2)
        encoder.setFragmentTexture(textures.backDepth, index: 3)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
    }

    /// One frame as an image (tests and diagnostics).
    func image(_ textures: Textures, look: SIMD2<Float>, zoom: Float, width: Int, height: Int) -> CGImage? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Self.pixelFormat, width: width, height: height, mipmapped: false)
        descriptor.usage = [.renderTarget, .shaderRead]
        guard let target = device.makeTexture(descriptor: descriptor), let buffer = queue.makeCommandBuffer() else { return nil }
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = target
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store
        encode(textures, look: look, zoom: zoom, pass: pass, into: buffer)
        buffer.commit()
        buffer.waitUntilCompleted()
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        target.getBytes(&bytes, bytesPerRow: width * 4, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        guard let space = CGColorSpace(name: CGColorSpace.displayP3), let provider = CGDataProvider(data: Data(bytes) as CFData) else { return nil }
        let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        return CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4, space: space,
                       bitmapInfo: info, provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }

    private static let shader = """
    #include <metal_stdlib>
    using namespace metal;

    struct Vertex {
        float4 position [[position]];
        float2 uv;
    };

    struct Uniforms {
        float2 offset;
        float focus;
        float zoom;
        float2 texel;
        float2 padding;
    };

    vertex Vertex spatial_vertex(uint id [[vertex_id]]) {
        float2 corner = float2((id << 1) & 2, id & 2);
        Vertex out;
        out.position = float4(corner * 2.0 - 1.0, 0.0, 1.0);
        out.uv = float2(corner.x, 1.0 - corner.y);
        return out;
    }

    fragment float4 spatial_fragment(Vertex in [[stage_in]],
                                     constant Uniforms &u [[buffer(0)]],
                                     texture2d<float> color [[texture(0)]],
                                     texture2d<float> depth [[texture(1)]],
                                     texture2d<float> backColor [[texture(2)]],
                                     texture2d<float> backDepth [[texture(3)]]) {
        constexpr sampler bilinear(filter::linear, mip_filter::linear, address::clamp_to_edge);
        float2 p = (in.uv - 0.5) / u.zoom + 0.5;
        float2 o = u.offset;
        float2 dx = dfdx(p), dy = dfdy(p);
        if (dot(o, o) < 1e-12) {
            return float4(color.sample(bilinear, p, gradient2d(dx, dy)).rgb, 1.0);
        }

        // A point at `uv` with nearness d is seen at uv + o * (d - focus). Walk from the nearest
        // level to the farthest; the first level at which the scene is at least that near is what's seen.
        const int steps = 14;
        float inside = 0.0, outside = 1.0;
        for (int i = 0; i <= steps; i++) {
            float nearness = 1.0 - float(i) / float(steps);
            float2 uv = p - o * (nearness - u.focus);
            if (depth.sample(bilinear, uv, level(0.0)).r >= nearness) { inside = nearness; break; }
            outside = nearness;
        }
        for (int i = 0; i < 4; i++) {
            float middle = 0.5 * (inside + outside);
            float2 uv = p - o * (middle - u.focus);
            if (depth.sample(bilinear, uv, level(0.0)).r >= middle) { inside = middle; } else { outside = middle; }
        }
        float2 hit = p - o * (inside - u.focus);
        float3 front = color.sample(bilinear, hit, gradient2d(dx, dy)).rgb;

        // How far one texel is stretched along the view shift: a big stretch is a gap opening behind something.
        float2 e = u.texel * 1.5;
        float gx = (depth.sample(bilinear, hit + float2(e.x, 0.0), level(0.0)).r - depth.sample(bilinear, hit - float2(e.x, 0.0), level(0.0)).r) / (2.0 * e.x);
        float gy = (depth.sample(bilinear, hit + float2(0.0, e.y), level(0.0)).r - depth.sample(bilinear, hit - float2(0.0, e.y), level(0.0)).r) / (2.0 * e.y);
        float gap = smoothstep(0.5, 1.5, o.x * gx + o.y * gy);
        if (gap <= 0.001) {
            return float4(front, 1.0);
        }
        float2 behind = p - o * (backDepth.sample(bilinear, p, level(0.0)).r - u.focus);
        behind = p - o * (backDepth.sample(bilinear, behind, level(0.0)).r - u.focus);
        float3 back = backColor.sample(bilinear, behind, level(0.0)).rgb;
        return float4(mix(front, back, gap), 1.0);
    }
    """
}

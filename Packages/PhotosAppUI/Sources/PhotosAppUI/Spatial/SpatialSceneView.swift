import MetalKit
import UIKit
import simd

/// Shows a spatial scene and moves the viewpoint as the iPhone tilts.
/// It draws only while something changes, so a still phone costs nothing.
@MainActor
final class SpatialSceneView: MTKView, MTKViewDelegate {
    private let renderer: SpatialRenderer
    private let textures: SpatialRenderer.Textures
    private let motion = SpatialMotion()

    /// Set to steer the view by hand (tests); nil follows the iPhone's motion.
    var manualLook: SIMD2<Float>? { didSet { needsFrame = true } }
    private var look = SIMD2<Float>(0, 0)
    private var zoom: Float = 1
    private var drawnLook = SIMD2<Float>(9, 9)
    private var drawnZoom: Float = 0
    private var needsFrame = true
    private var appeared: CFTimeInterval?
    private var lastFrame: CFTimeInterval = 0
    private var firstFrame: [() -> Void] = []
    private var hasDrawn = false
    /// Recent GPU times; a slow phone drops to a lighter resolution.
    private var gpuTimes: [Double] = []
    private var didTuneResolution = false
    private(set) var averageGPUTime = 0.0

    init?(scene: SpatialScene) {
        guard let renderer = SpatialRenderer.shared, let textures = renderer.textures(for: scene) else { return nil }
        self.renderer = renderer
        self.textures = textures
        super.init(frame: .zero, device: renderer.device)
        colorPixelFormat = SpatialRenderer.pixelFormat
        (layer as? CAMetalLayer)?.colorspace = CGColorSpace(name: CGColorSpace.displayP3)
        framebufferOnly = true
        isOpaque = true
        isUserInteractionEnabled = false
        preferredFramesPerSecond = 60
        enableSetNeedsDisplay = false
        isPaused = true
        delegate = self
        // Selector observers are dropped by the system when the view goes away.
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc private func appWillResignActive() { setRunning(false) }
    @objc private func appDidBecomeActive() { setRunning(window != nil) }

    @available(*, unavailable)
    required init(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        setRunning(window != nil && UIApplication.shared.applicationState == .active)
    }

    private func setRunning(_ running: Bool) {
        isPaused = !running
        if running {
            motion.start(orientation: window?.windowScene?.interfaceOrientation ?? .portrait)
            needsFrame = true
        } else {
            motion.stop()
        }
    }

    /// Stops drawing and listening to motion (the view is about to go away).
    func shutDown() {
        setRunning(false)
    }

    /// Calls back once the first frame is on screen (at once if it already is).
    func whenFirstFrameShown(_ action: @escaping () -> Void) {
        if hasDrawn { action() } else { firstFrame.append(action) }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        needsFrame = true
        motion.set(orientation: window?.windowScene?.interfaceOrientation ?? .portrait)
    }

    func draw(in view: MTKView) {
        let now = CACurrentMediaTime()
        let started = appeared ?? now
        if appeared == nil { appeared = now; lastFrame = now }
        let dt = Float(min(max(now - lastFrame, 0), 0.1))
        lastFrame = now
        let age = Float(now - started)

        // Opening: ease in to the zoomed view with a small sideways move that shows the depth at once.
        let opening = min(age / 1.1, 1)
        let eased = 1 - pow(1 - opening, 3)
        zoom = 1 + (SpatialRenderer.activeZoom - 1) * eased
        var target = manualLook ?? motion.look
        if manualLook == nil { target += SIMD2<Float>(0.55, -0.2) * (1 - eased) * sin(opening * .pi) * 1.6 }
        look += (target - look) * (1 - exp(-dt * 12))

        let moved = simd_distance(look, drawnLook) > 0.0015 || abs(zoom - drawnZoom) > 0.0002
        guard needsFrame || moved else { return }
        guard let drawable = currentDrawable, let pass = currentRenderPassDescriptor, let buffer = renderer.makeCommandBuffer() else { return }
        needsFrame = false
        drawnLook = look
        drawnZoom = zoom
        renderer.encode(textures, look: look, zoom: zoom, pass: pass, into: buffer)
        buffer.present(drawable)
        buffer.addCompletedHandler { [weak self] finished in
            let seconds = finished.gpuEndTime - finished.gpuStartTime
            Task { @MainActor in self?.frameFinished(gpuSeconds: seconds) }
        }
        buffer.commit()
    }

    private func frameFinished(gpuSeconds: Double) {
        if !hasDrawn {
            hasDrawn = true
            let actions = firstFrame
            firstFrame = []
            actions.forEach { $0() }
        }
        guard gpuSeconds > 0, !didTuneResolution else { return }
        gpuTimes.append(gpuSeconds)
        guard gpuTimes.count >= 24 else { return }
        // Skip the first frames (shader warm-up), then judge.
        averageGPUTime = gpuTimes.dropFirst(8).reduce(0, +) / Double(gpuTimes.count - 8)
        didTuneResolution = true
        if averageGPUTime > 0.010, contentScaleFactor > 2 {
            contentScaleFactor = 2
            needsFrame = true
        }
    }
}

import CoreMotion
import UIKit
import simd

/// Turns tilting the iPhone into a viewpoint: -1…1 across and up/down, 0 when held as it was
/// when the scene opened. Holding a new angle slowly becomes the new "straight on".
@MainActor
final class SpatialMotion {
    private static let manager = CMMotionManager()
    /// About 8° of tilt reaches most of the range.
    private static let fullTilt = 0.14

    private(set) var look = SIMD2<Float>(0, 0)
    var isAvailable: Bool { Self.manager.isDeviceMotionAvailable }
    private var baseline: (roll: Double, pitch: Double)?
    private var orientation = UIInterfaceOrientation.portrait
    private var isRunning = false

    func start(orientation: UIInterfaceOrientation) {
        self.orientation = orientation
        guard !isRunning, Self.manager.isDeviceMotionAvailable else { return }
        isRunning = true
        baseline = nil
        look = .zero
        Self.manager.deviceMotionUpdateInterval = 1.0 / 60
        Self.manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let attitude = motion?.attitude else { return }
            let roll = attitude.roll, pitch = attitude.pitch
            MainActor.assumeIsolated { self?.update(roll: roll, pitch: pitch) }
        }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        Self.manager.stopDeviceMotionUpdates()
        look = .zero
    }

    func set(orientation: UIInterfaceOrientation) {
        guard orientation != self.orientation else { return }
        self.orientation = orientation
        baseline = nil
    }

    private func update(roll: Double, pitch: Double) {
        guard isRunning else { return }
        guard var base = baseline else {
            baseline = (roll, pitch)
            return
        }
        func wrapped(_ angle: Double) -> Double {
            var value = angle
            while value > .pi { value -= 2 * .pi }
            while value < -.pi { value += 2 * .pi }
            return value
        }
        let dRoll = wrapped(roll - base.roll), dPitch = wrapped(pitch - base.pitch)
        // Drift back to centre over several seconds.
        base.roll += dRoll * 0.003
        base.pitch += dPitch * 0.003
        baseline = base
        let across = Float(tanh(dRoll / Self.fullTilt)), along = Float(tanh(dPitch / Self.fullTilt))
        // Tilting the right side away puts the viewer to the left, so nearer things shift right;
        // tilting the top towards the viewer shifts them down. Turned sideways, the axes swap.
        switch orientation {
        case .landscapeRight: look = SIMD2(along, -across)
        case .landscapeLeft: look = SIMD2(-along, across)
        case .portraitUpsideDown: look = SIMD2(-across, -along)
        default: look = SIMD2(across, along)
        }
    }
}

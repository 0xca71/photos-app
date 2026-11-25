import Foundation
import Observation

/// The local timeout after which the app asks for its own password again.
public enum AppLockTimeout: Int, CaseIterable, Sendable {
    case immediately = 0
    case oneMinute = 60
    case fiveMinutes = 300
    case fifteenMinutes = 900
    case oneHour = 3600

    public var duration: TimeInterval { TimeInterval(rawValue) }
}

public enum AppLockError: Error, Equatable, Sendable {
    case invalidPassword
    case storage
}

/// Local app-lock state. The password is stored in the device-only Keychain and is never sent to Cloud.
@MainActor
@Observable
public final class AppLockStore {
    private static let passwordKey = "app-lock.password"
    private static let timeoutKey = "app-lock.timeout"

    private let defaults: UserDefaults
    private let secrets: any SecretStore
    private var inactiveAt: Date?

    public private(set) var isEnabled: Bool
    public private(set) var timeout: AppLockTimeout
    public private(set) var isLocked: Bool

    public init(defaults: UserDefaults = .standard, secrets: any SecretStore = KeychainStore(service: "com.ethwood.photos.app-lock")) {
        self.defaults = defaults
        self.secrets = secrets
        let enabled = (try? secrets.read(Self.passwordKey)) != nil
        isEnabled = enabled
        timeout = AppLockTimeout(rawValue: defaults.integer(forKey: Self.timeoutKey)) ?? .immediately
        isLocked = enabled
    }

    public func setUp(password: String, timeout: AppLockTimeout) throws {
        guard Self.isValidPassword(password) else { throw AppLockError.invalidPassword }
        do {
            try secrets.write(password, for: Self.passwordKey)
        } catch {
            throw AppLockError.storage
        }
        defaults.set(timeout.rawValue, forKey: Self.timeoutKey)
        self.timeout = timeout
        isEnabled = true
        isLocked = false
        inactiveAt = nil
    }

    public func changePassword(current: String, replacement: String) throws {
        guard verify(current) else { throw AppLockError.invalidPassword }
        guard Self.isValidPassword(replacement) else { throw AppLockError.invalidPassword }
        do {
            try secrets.write(replacement, for: Self.passwordKey)
        } catch {
            throw AppLockError.storage
        }
    }

    @discardableResult
    public func disable(password: String) -> Bool {
        guard verify(password) else { return false }
        try? secrets.delete(Self.passwordKey)
        defaults.removeObject(forKey: Self.timeoutKey)
        isEnabled = false
        isLocked = false
        inactiveAt = nil
        return true
    }

    public func setTimeout(_ timeout: AppLockTimeout) {
        guard isEnabled else { return }
        self.timeout = timeout
        defaults.set(timeout.rawValue, forKey: Self.timeoutKey)
    }

    @discardableResult
    public func unlock(password: String) -> Bool {
        guard verify(password) else { return false }
        isLocked = false
        inactiveAt = nil
        return true
    }

    /// Records the first moment the app leaves the foreground. The root view uses this
    /// state to cover the app before iOS captures the app-switcher snapshot.
    public func sceneBecameInactive(at date: Date = .now) {
        guard isEnabled else { return }
        inactiveAt = inactiveAt ?? date
        if timeout == .immediately { isLocked = true }
    }

    /// Re-evaluates the timeout when the app becomes active again.
    public func sceneBecameActive(at date: Date = .now) {
        guard isEnabled else { return }
        if let inactiveAt, timeout == .immediately || date.timeIntervalSince(inactiveAt) >= timeout.duration {
            isLocked = true
        }
        if !isLocked { self.inactiveAt = nil }
    }

    public static func isValidPassword(_ password: String) -> Bool {
        (password.count == 4 || password.count == 6) && password.allSatisfy { $0.isASCII && $0.isNumber }
    }

    private func verify(_ password: String) -> Bool {
        guard let stored = try? secrets.read(Self.passwordKey) else { return false }
        return stored == password
    }
}

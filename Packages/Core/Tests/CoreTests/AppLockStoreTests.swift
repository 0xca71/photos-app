import Foundation
import Testing
@testable import Core

@MainActor
@Suite struct AppLockStoreTests {
    private func makeDefaults() -> UserDefaults {
        let name = "app-lock-test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test func acceptsOnlyFourOrSixAsciiDigits() {
        #expect(AppLockStore.isValidPassword("1234"))
        #expect(AppLockStore.isValidPassword("123456"))
        #expect(!AppLockStore.isValidPassword("123"))
        #expect(!AppLockStore.isValidPassword("12345"))
        #expect(!AppLockStore.isValidPassword("１２３４"))
        #expect(!AppLockStore.isValidPassword("12ab"))
    }

    @Test func setupUnlocksAndPersistsTimeout() throws {
        let defaults = makeDefaults()
        let secrets = InMemorySecretStore()
        let store = AppLockStore(defaults: defaults, secrets: secrets)
        try store.setUp(password: "1234", timeout: .fiveMinutes)
        #expect(store.isEnabled)
        #expect(!store.isLocked)
        #expect(store.passwordLength == 4)
        #expect(store.timeout == .fiveMinutes)

        let reloaded = AppLockStore(defaults: defaults, secrets: secrets)
        #expect(reloaded.isEnabled)
        #expect(reloaded.isLocked)
        #expect(reloaded.passwordLength == 4)
        #expect(reloaded.timeout == .fiveMinutes)
    }

    @Test func timeoutLocksAfterReturningFromBackground() throws {
        let store = AppLockStore(defaults: makeDefaults(), secrets: InMemorySecretStore())
        try store.setUp(password: "123456", timeout: .oneMinute)
        let start = Date(timeIntervalSince1970: 10_000)
        store.sceneBecameInactive(at: start)
        store.sceneBecameActive(at: start.addingTimeInterval(30))
        #expect(!store.isLocked)
        store.sceneBecameInactive(at: start.addingTimeInterval(40))
        store.sceneEnteredBackground(at: start.addingTimeInterval(40))
        store.sceneBecameActive(at: start.addingTimeInterval(101))
        #expect(store.isLocked)
        #expect(!store.unlock(password: "000000"))
        #expect(store.unlock(password: "123456"))
        #expect(!store.isLocked)
    }

    @Test func appSwitcherDoesNotLockImmediately() throws {
        let store = AppLockStore(defaults: makeDefaults(), secrets: InMemorySecretStore())
        try store.setUp(password: "1234", timeout: .immediately)
        let start = Date(timeIntervalSince1970: 10_000)
        store.sceneBecameInactive(at: start)
        #expect(!store.isLocked)
        store.sceneBecameActive(at: start.addingTimeInterval(1))
        #expect(!store.isLocked)
    }

    @Test func immediateTimeoutLocksAfterEnteringBackground() throws {
        let store = AppLockStore(defaults: makeDefaults(), secrets: InMemorySecretStore())
        try store.setUp(password: "1234", timeout: .immediately)
        let start = Date(timeIntervalSince1970: 10_000)
        store.sceneBecameInactive(at: start)
        store.sceneEnteredBackground(at: start.addingTimeInterval(1))
        #expect(store.isLocked)
    }

    @Test func infersPasswordLengthForExistingInstall() throws {
        let defaults = makeDefaults()
        let secrets = InMemorySecretStore()
        let store = AppLockStore(defaults: defaults, secrets: secrets)
        try store.setUp(password: "1234", timeout: .immediately)
        defaults.removeObject(forKey: "app-lock.password-length")

        let reloaded = AppLockStore(defaults: defaults, secrets: secrets)
        #expect(reloaded.passwordLength == 4)
    }
}

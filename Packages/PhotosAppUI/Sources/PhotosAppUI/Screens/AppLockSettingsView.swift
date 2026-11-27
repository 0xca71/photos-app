import Core
import SwiftUI

struct AppLockSettingsView: View {
    let appLock: AppLockStore
    @State private var sheet: AppLockSheet?

    var body: some View {
        List {
            Section {
                if appLock.isEnabled {
                    Picker("Require Password", selection: Binding(
                        get: { appLock.timeout },
                        set: { appLock.setTimeout($0) }
                    )) {
                        ForEach(AppLockTimeout.allCases, id: \.self) { timeout in
                            Text(timeout.title).tag(timeout)
                        }
                    }
                    Button("Change App Lock Password") { sheet = .change }
                    Button("Turn Off App Lock", role: .destructive) { sheet = .disable }
                } else {
                    Button("Set Up App Lock") { sheet = .setup }
                }
            } footer: {
                Text("App Lock protects this app on this iPhone. It is stored locally and is unrelated to your Cloud server.")
            }
        }
        .navigationTitle("App Lock")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                AppLockPasswordSheet(action: sheet, appLock: appLock) {
                    self.sheet = nil
                }
            }
            .presentationDetents([.medium])
        }
    }
}

private enum AppLockSheet: String, Identifiable {
    case setup
    case change
    case disable

    var id: String { rawValue }
}

private struct AppLockPasswordSheet: View {
    let action: AppLockSheet
    let appLock: AppLockStore
    let onDone: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var password = ""
    @State private var confirmation = ""
    @State private var timeout: AppLockTimeout = .immediately
    @State private var error: String?

    var body: some View {
        Form {
            if action == .change || action == .disable {
                Section {
                    PasswordField(title: "Current Password", password: $currentPassword)
                }
            }
            if action != .disable {
                Section {
                    PasswordField(title: "New Password", password: $password)
                    PasswordField(title: "Confirm Password", password: $confirmation)
                } footer: {
                    Text("Choose a 4- or 6-digit password.")
                }
            }
            if action == .setup {
                Section("Require Password") {
                    Picker("Require Password", selection: $timeout) {
                        ForEach(AppLockTimeout.allCases, id: \.self) { value in
                            Text(value.title).tag(value)
                        }
                    }
                }
            }
            if let error {
                Text(error).foregroundStyle(.red)
            }
            Section {
                Button(action == .disable ? "Turn Off App Lock" : action == .change ? "Change Password" : "Set Up App Lock") {
                    submit()
                }
                .disabled(!canSubmit)
            }
        }
        .navigationTitle(action.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { close() }
            }
        }
    }

    private var canSubmit: Bool {
        switch action {
        case .disable: AppLockStore.isValidPassword(currentPassword)
        case .setup, .change: AppLockStore.isValidPassword(password) && password == confirmation && (action == .setup || AppLockStore.isValidPassword(currentPassword))
        }
    }

    private func submit() {
        do {
            switch action {
            case .setup:
                try appLock.setUp(password: password, timeout: timeout)
            case .change:
                try appLock.changePassword(current: currentPassword, replacement: password)
            case .disable:
                guard appLock.disable(password: currentPassword) else {
                    error = String(localized: "Incorrect password.")
                    return
                }
            }
            close()
        } catch AppLockError.invalidPassword {
            error = String(localized: "The password must be 4 or 6 digits.")
        } catch {
            error = String(localized: "Couldn’t Complete")
        }
    }

    private func close() {
        onDone()
        dismiss()
    }
}

private struct PasswordField: View {
    let title: LocalizedStringKey
    @Binding var password: String

    var body: some View {
        SecureField(title, text: $password)
            .keyboardType(.numberPad)
            .onChange(of: password) { _, value in
                let digits = value.filter { $0.isASCII && $0.isNumber }
                password = String(digits.prefix(6))
            }
    }
}

private extension AppLockTimeout {
    var title: LocalizedStringKey {
        switch self {
        case .immediately: "Immediately"
        case .oneMinute: "After 1 Minute"
        case .fiveMinutes: "After 5 Minutes"
        case .fifteenMinutes: "After 15 Minutes"
        case .oneHour: "After 1 Hour"
        }
    }
}

private extension AppLockSheet {
    var title: LocalizedStringKey {
        switch self {
        case .setup: "Set Up App Lock"
        case .change: "Change App Lock Password"
        case .disable: "Turn Off App Lock"
        }
    }
}

import Core
import SwiftUI

struct AppLockUnlockView: View {
    let appLock: AppLockStore
    @State private var password = ""
    @State private var showsError = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.tint)
            Text("The app is locked")
                .font(.title2.weight(.semibold))
            SecureField("Enter your app password.", text: $password)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 220)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .onSubmit(unlock)
            if showsError {
                Text("Incorrect password.")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            Button("Unlock", action: unlock)
                .buttonStyle(.borderedProminent)
                .disabled(password.isEmpty)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .accessibilityElement(children: .contain)
    }

    private func unlock() {
        showsError = !appLock.unlock(password: password)
        if !showsError { password = "" }
    }
}

import Core
import SwiftUI
import UIKit

struct AppLockUnlockView: View {
    let appLock: AppLockStore
    private let digitRows = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
    ]
    @State private var password = ""
    @State private var showsError = false

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "lock.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.tint)
                Text("The app is locked")
                    .font(.title2.weight(.semibold))

                HStack(spacing: 12) {
                    ForEach(0..<appLock.passwordLength, id: \.self) { index in
                        Circle()
                            .fill(index < password.count ? Color.primary : Color.clear)
                            .frame(width: 14, height: 14)
                            .overlay {
                                Circle()
                                    .stroke(Color.primary, lineWidth: 1)
                            }
                    }
                }
                .accessibilityHidden(true)

                if showsError {
                    Text("Incorrect password.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                keypad

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .accessibilityElement(children: .contain)
    }

    private var keypad: some View {
        VStack(spacing: 14) {
            ForEach(digitRows, id: \.self) { row in
                HStack(spacing: 18) {
                    ForEach(row, id: \.self, content: digitButton)
                }
            }
            HStack(spacing: 18) {
                Color.clear
                    .frame(width: 72, height: 72)
                digitButton("0")
                Button { deleteLastDigit() } label: {
                    Image(systemName: "delete.left")
                        .font(.title3)
                        .frame(width: 72, height: 72)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Delete"))
            }
        }
    }

    private func digitButton(_ digit: String) -> some View {
        Button(digit) { append(digit) }
            .font(.system(size: 28, weight: .regular, design: .rounded))
            .frame(width: 72, height: 72)
            .background(Color.secondary.opacity(0.12), in: Circle())
            .buttonStyle(.plain)
            .accessibilityLabel(Text(digit))
    }

    private func append(_ digit: String) {
        guard password.count < appLock.passwordLength else { return }
        showsError = false
        password.append(digit)
        if password.count == appLock.passwordLength {
            unlock()
        }
    }

    private func deleteLastDigit() {
        guard !password.isEmpty else { return }
        showsError = false
        password.removeLast()
    }

    private func unlock() {
        let unlocked = appLock.unlock(password: password)
        showsError = !unlocked
        password = ""
    }
}

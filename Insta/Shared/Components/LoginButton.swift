import SwiftUI

/// A full-width login button styled to match the Figma `auth/button-login` component.
struct LoginButton: View {
    var title: String = "Log in"
    var isLoading: Bool = false
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .font(.system(size: 14.5, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                Color.grainCoral.opacity(isEnabled ? 1 : 0.5),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading || !isEnabled)
    }
}

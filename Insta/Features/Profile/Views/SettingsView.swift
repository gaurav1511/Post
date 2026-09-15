import SwiftUI

// MARK: - Settings Screen

/// A dedicated settings screen pushed from the profile's burger menu. Hosts the
/// appearance (light/dark) control and the log-out action.
struct SettingsView: View {
    @Binding var appTheme: AppTheme
    let onLogout: () async -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            appearanceSection

            Spacer()

            Button(role: .destructive) {
                Task {
                    await onLogout()
                    dismiss()
                }
            } label: {
                Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.grainField, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .tint(Color.grainCoral)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.grainBackground)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Appearance

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("APPEARANCE")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.grainTextMuted)

            HStack {
                Label("Theme", systemImage: appTheme == .dark ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.grainTextPrimary)

                Spacer()

                Picker("Theme", selection: $appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.label).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.grainField, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

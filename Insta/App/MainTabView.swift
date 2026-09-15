import SwiftUI

// MARK: - Main Tab Container

/// Root container for the signed-in experience. Owns the selected tab and swaps
/// the active screen inline above a single persistent tab bar — no screen is
/// presented modally.
struct MainTabView: View {
    @State private var selectedTab: HomeTab = .home

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            HomeTabBar(selection: $selectedTab)
        }
        .background(Color.grainBackground)
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .profile:
            ProfileView()
        case .search, .create, .reels:
            ComingSoonView()
        }
    }
}

/// Placeholder for tabs that don't have a screen yet.
private struct ComingSoonView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundStyle(Color.grainTextMuted)
            Text("Coming soon")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.grainTextMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.grainBackground)
    }
}

#Preview {
    MainTabView()
}

import SwiftUI

/// The app's primary navigation destinations.
enum HomeTab: Hashable {
    case home, search, create, reels, profile
}

/// Bottom navigation bar matching the Figma feed's five destinations.
struct HomeTabBar: View {
    @Binding var selection: HomeTab

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(Color.grainBorder)

            HStack {
                tabButton(.home, systemImage: selection == .home ? "house.fill" : "house")
                Spacer()
                tabButton(.search, systemImage: "magnifyingglass")
                Spacer()
                createButton
                Spacer()
                tabButton(.reels, systemImage: "play.rectangle")
                Spacer()
                tabButton(.profile, systemImage: "person")
            }
            .padding(.horizontal, 28)
            .padding(.top, 12)
            .padding(.bottom, 4)
        }
        .background(Color.grainBackground)
    }

    private func tabButton(_ tab: HomeTab, systemImage: String) -> some View {
        Button {
            selection = tab
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 23, weight: .regular))
                .foregroundStyle(selection == tab ? Color.grainTextPrimary : Color.grainTextMuted)
        }
    }

    private var createButton: some View {
        Button {
            selection = .create
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(Color.grainTextPrimary)
                .frame(width: 34, height: 34)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.grainTextPrimary, lineWidth: 1.8)
                )
        }
    }
}

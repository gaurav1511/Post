import SwiftUI

// MARK: - Profile Screen

/// Recreation of the Figma "03-profile" screen: a GRAIN profile with header,
/// stats, bio, action buttons, story highlights, a tab strip, and a post grid.
/// The bottom tab bar is owned by `MainTabView`.
struct ProfileView: View {
    @State private var selectedContentTab: ProfileContentTab = .grid
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    summary
                    bio
                    actions
                    highlights
                    contentTabs
                    postGrid
                }
                .padding(.top, 12)
            }
        }
        .background(Color.grainBackground)
        .task { await viewModel.load() }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button {} label: {
                HStack(spacing: 6) {
                    Text(viewModel.handle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.grainTextPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.grainTextPrimary)
                }
            }

            Spacer()

            Button {} label: {
                Image(systemName: "plus.app")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color.grainTextPrimary)
            }

            Button {} label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color.grainTextPrimary)
            }
            .padding(.leading, 20)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    // MARK: Avatar + Stats

    private var summary: some View {
        HStack(spacing: 28) {
            AvatarCircle(size: 84)
                .overlay {
                    Circle().strokeBorder(
                        LinearGradient(
                            colors: [Color.grainCoral, Color(hex: "C13584"), Color(hex: "F9CE34")],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        ),
                        lineWidth: 2.5
                    )
                }

            HStack(spacing: 0) {
                stat(viewModel.profile.postsCount, "posts")
                stat(viewModel.profile.followersCount, "followers")
                stat(viewModel.profile.followingCount, "following")
            }
        }
        .padding(.horizontal, 24)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.grainTextPrimary)
            Text(label)
                .font(.system(size: 11.5))
                .foregroundStyle(Color.grainTextMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Bio

    private var bio: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.name)
                .font(.system(size: 13.5, weight: .bold))
                .foregroundStyle(Color.grainTextPrimary)
            Text(viewModel.profile.tagline)
                .font(.system(size: 12.5))
                .foregroundStyle(Color.grainTextMuted)
            HStack(spacing: 6) {
                Image(systemName: "square.stack")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.grainCoral)
                Text(viewModel.profile.link)
                    .font(.system(size: 12.5))
                    .foregroundStyle(Color.grainCoral)
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 24)
    }

    // MARK: Actions

    private var actions: some View {
        HStack(spacing: 8) {
            Button {} label: {
                Text("Follow")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(Color.grainCoral, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {} label: {
                Text("Message")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.grainTextPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(Color.grainField, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {} label: {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.grainTextPrimary)
                    .frame(width: 40, height: 34)
                    .background(Color.grainField, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
    }

    // MARK: Highlights

    private var highlights: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(viewModel.profile.highlights) { highlight in
                    VStack(spacing: 6) {
                        AvatarCircle(size: 54)
                            .overlay {
                                Circle().strokeBorder(Color.grainBorder, lineWidth: 1.5)
                            }
                        Text(highlight.title)
                            .font(.system(size: 10.5))
                            .foregroundStyle(Color.grainTextMuted)
                            .lineLimit(1)
                    }
                    .frame(width: 60)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: Content Tabs

    private var contentTabs: some View {
        HStack(spacing: 0) {
            contentTab(.grid, systemImage: "square.grid.3x3")
            contentTab(.reels, systemImage: "play.rectangle")
            contentTab(.tagged, systemImage: "tag")
        }
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.grainBorder)
        }
    }

    private func contentTab(_ tab: ProfileContentTab, systemImage: String) -> some View {
        Button {
            selectedContentTab = tab
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(selectedContentTab == tab ? Color.grainTextPrimary : Color.grainTextMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    if selectedContentTab == tab {
                        Rectangle()
                            .fill(Color.grainTextPrimary)
                            .frame(height: 1.5)
                    }
                }
        }
    }

    // MARK: Post Grid

    private var postGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(viewModel.profile.tiles) { tile in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "24303A"), Color(hex: "0E1418")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(alignment: .topTrailing) {
                        if let icon = tile.overlayIcon {
                            Image(systemName: icon)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(6)
                        }
                    }
            }
        }
    }
}

#Preview {
    ProfileView()
}

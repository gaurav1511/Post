import SwiftUI

// MARK: - Home Screen

/// Recreation of the Figma "01-feed" screen: a GRAIN feed with a header,
/// stories rail, and posts. The bottom tab bar is owned by `MainTabView`.
struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    storiesRail
                    Divider()
                        .overlay(Color.grainBorder)
                    ForEach(viewModel.posts) { post in
                        PostCard(post: post)
                    }
                }
            }
        }
        .background(Color.grainBackground)
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Text("GRAIN")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Color.grainTextPrimary)

            Spacer()

            Button {} label: {
                Image(systemName: "bell")
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(Color.grainTextPrimary)
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(Color.grainCoral)
                            .frame(width: 7, height: 7)
                            .offset(x: 2, y: -1)
                    }
            }

            Button {} label: {
                Image(systemName: "paperplane")
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(Color.grainTextPrimary)
            }
            .padding(.leading, 20)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    // MARK: Stories

    private var storiesRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                StoryItem(story: viewModel.yourStory)
                ForEach(viewModel.stories) { story in
                    StoryItem(story: story)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Story Item

/// A single story avatar with its ring style and username caption.
struct StoryItem: View {
    let story: Story

    var body: some View {
        VStack(spacing: 8) {
            avatar
            Text(story.username)
                .font(.system(size: 10.5))
                .foregroundStyle(story.isYours ? Color.grainLabel : Color.grainTextMuted)
                .lineLimit(1)
        }
        .frame(width: 64)
    }

    private var avatar: some View {
        AvatarCircle(size: 58)
            .overlay { ringOverlay }
            .overlay(alignment: .bottomTrailing) { addBadge }
            .overlay(alignment: .top) { liveBadge }
    }

    @ViewBuilder
    private var ringOverlay: some View {
        switch story.ring {
        case .unseen:
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.grainCoral, Color(hex: "C13584"), Color(hex: "F9CE34")],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    ),
                    lineWidth: 2
                )
        case .live, .seen, .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private var addBadge: some View {
        if story.isYours {
            Image(systemName: "plus")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Color.grainCoral, in: Circle())
                .overlay(Circle().stroke(Color.grainBackground, lineWidth: 2))
        }
    }

    @ViewBuilder
    private var liveBadge: some View {
        if story.ring == .live {
            Text("LIVE")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.grainCoral, in: Capsule())
                .overlay(Capsule().stroke(Color.grainBackground, lineWidth: 2))
                .offset(y: 46)
        }
    }
}

// MARK: - Post Card

/// A feed post: author header, image, action row, and metadata.
struct PostCard: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            postHeader
            postImage
            actions
            meta
        }
        .padding(.bottom, 8)
    }

    private var postHeader: some View {
        HStack(spacing: 10) {
            AvatarCircle(size: 32)
                .overlay {
                    Circle().strokeBorder(
                        LinearGradient(
                            colors: [Color.grainCoral, Color(hex: "C13584")],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        ),
                        lineWidth: 2
                    )
                }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(post.username)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.grainTextPrimary)
                    if post.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.grainCoral)
                    }
                }
                Text(post.location)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.grainTextMuted)
            }

            Spacer()

            Button {} label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.grainTextPrimary)
            }
        }
        .padding(.horizontal, 16)
    }

    private var postImage: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color(hex: "1E2A32"), Color(hex: "0E1418")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .topTrailing) {
                Text("1/3")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.5), in: Capsule())
                    .padding(12)
            }
            .overlay(alignment: .bottom) {
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == 0 ? Color.grainTextPrimary : Color.grainTextMuted.opacity(0.5))
                            .frame(width: 5, height: 5)
                    }
                }
                .padding(.bottom, 10)
            }
    }

    private var actions: some View {
        HStack(spacing: 18) {
            Image(systemName: "heart.fill")
                .foregroundStyle(Color.grainCoral)
            Image(systemName: "bubble.right")
                .foregroundStyle(Color.grainTextPrimary)
            Image(systemName: "paperplane")
                .foregroundStyle(Color.grainTextPrimary)
            Spacer()
            Image(systemName: "bookmark")
                .foregroundStyle(Color.grainTextPrimary)
        }
        .font(.system(size: 22, weight: .regular))
        .padding(.horizontal, 16)
    }

    private var meta: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                ZStack {
                    AvatarCircle(size: 15)
                        .overlay(Circle().stroke(Color.grainBackground, lineWidth: 1.5))
                    AvatarCircle(size: 15)
                        .overlay(Circle().stroke(Color.grainBackground, lineWidth: 1.5))
                        .offset(x: 10)
                }
                .frame(width: 25, alignment: .leading)

                Text("Liked by ")
                    .foregroundStyle(Color.grainTextPrimary)
                    .font(.system(size: 12.5))
                + Text("m_ferrer")
                    .foregroundStyle(Color.grainTextPrimary)
                    .font(.system(size: 12.5, weight: .bold))
                + Text(" and ")
                    .foregroundStyle(Color.grainTextPrimary)
                    .font(.system(size: 12.5))
                + Text("1,283 others")
                    .foregroundStyle(Color.grainTextPrimary)
                    .font(.system(size: 12.5, weight: .bold))
            }

            Text(post.username)
                .foregroundStyle(Color.grainTextPrimary)
                .font(.system(size: 12.5, weight: .bold))
            + Text("  \(post.caption)")
                .foregroundStyle(Color.grainTextMuted)
                .font(.system(size: 12.5))

            Text("View all \(post.commentCount) comments")
                .font(.system(size: 12))
                .foregroundStyle(Color.grainLabel)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    HomeView()
}

import Foundation

/// Which content grid the profile is showing.
enum ProfileContentTab: Hashable {
    case grid, reels, tagged
}

/// A story highlight bubble on the profile.
struct ProfileHighlight: Identifiable {
    let id = UUID()
    let title: String
}

/// A single tile in the profile's post grid.
struct ProfileTile: Identifiable {
    let id = UUID()
    var overlayIcon: String? = nil
}

/// The presentation content for a profile.
struct Profile {
    let username: String
    let displayName: String
    let tagline: String
    let subtitle: String
    let link: String
    let postsCount: String
    let followersCount: String
    let followingCount: String
    let highlights: [ProfileHighlight]
    let tiles: [ProfileTile]

    static let sample = Profile(
        username: "gaia.k",
        displayName: "Gaia Kovács",
        tagline: "Photographer · slow travel · film only",
        subtitle: "Zine 03 out now — 240 copies",
        link: "grain.co/gaia",
        postsCount: "214",
        followersCount: "18.4k",
        followingCount: "302",
        highlights: [
            ProfileHighlight(title: "Film"),
            ProfileHighlight(title: "Lisbon"),
            ProfileHighlight(title: "35mm"),
            ProfileHighlight(title: "Studio"),
            ProfileHighlight(title: "2025")
        ],
        tiles: [
            ProfileTile(),
            ProfileTile(overlayIcon: "square.on.square"),
            ProfileTile(),
            ProfileTile(overlayIcon: "play.rectangle"),
            ProfileTile(),
            ProfileTile(),
            ProfileTile(),
            ProfileTile(),
            ProfileTile()
        ]
    )

    /// A blank profile with zeroed counts and no content, used until real data
    /// is available so the screen shows genuine empty states instead of the
    /// sample placeholders.
    static let empty = Profile(
        username: "",
        displayName: "",
        tagline: "",
        subtitle: "",
        link: "",
        postsCount: "0",
        followersCount: "0",
        followingCount: "0",
        highlights: [],
        tiles: []
    )
}

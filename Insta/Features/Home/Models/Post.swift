import Foundation

/// A single feed post.
struct Post: Identifiable {
    let id = UUID()
    let username: String
    let isVerified: Bool
    let location: String
    let caption: String
    let commentCount: Int

    static let sample = Post(
        username: "gaia.k",
        isVerified: true,
        location: "Cais do Sodré, Lisbon",
        caption: "blue hour, 12 sec exposure. the river",
        commentCount: 42
    )
}

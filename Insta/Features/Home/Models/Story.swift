import Foundation

/// The ring style shown around a story avatar.
enum StoryRing {
    case unseen, live, seen, none
}

/// A single story in the home feed's stories rail.
struct Story: Identifiable {
    let id = UUID()
    let username: String
    let ring: StoryRing
    var isYours = false

    static let yourStory = Story(username: "Your story", ring: .none, isYours: true)

    static let samples: [Story] = [
        Story(username: "gaia.k", ring: .unseen),
        Story(username: "m_ferrer", ring: .unseen),
        Story(username: "atlas.co", ring: .live),
        Story(username: "noor.rt", ring: .seen)
    ]
}

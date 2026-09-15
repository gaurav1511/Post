import Foundation

/// Backs the home feed, exposing the stories rail and the feed posts.
/// Currently serves sample content until backed by real data.
@MainActor
@Observable
final class HomeViewModel {
    private(set) var yourStory: Story = .yourStory
    private(set) var stories: [Story] = Story.samples
    private(set) var posts: [Post] = [.sample]
}

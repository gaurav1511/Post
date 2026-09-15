import Foundation
import Supabase

/// Backs the profile screen. Loads the signed-in user's identity from the
/// Supabase auth record (username, full name, email stored as user metadata at
/// signup) and exposes the display content the view renders.
@MainActor
@Observable
final class ProfileViewModel {
    /// Static presentation content (stats, bio, highlights, grid) until these
    /// are backed by their own tables.
    private(set) var profile: Profile = .sample

    var username = ""
    var displayName = ""
    var email = ""

    var isLoading = true
    var errorMessage: String?

    /// The header/username line, falling back to the email's local part.
    var handle: String {
        if !username.isEmpty { return username }
        if let local = email.split(separator: "@").first { return String(local) }
        return "profile"
    }

    /// The bio display name, falling back to the sample content when unset.
    var name: String {
        displayName.isEmpty ? profile.displayName : displayName
    }

    /// Fetches the current user and populates the fields from its metadata.
    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await SupabaseManager.client.auth.user()
            username = user.userMetadata["username"]?.stringValue ?? ""
            displayName = user.userMetadata["full_name"]?.stringValue ?? ""
            email = user.email ?? ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

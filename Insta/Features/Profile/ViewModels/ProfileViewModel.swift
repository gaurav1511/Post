import Foundation
import Supabase

/// Backs the profile screen. Loads the signed-in user's identity from the
/// Supabase auth record (username, full name, email stored as user metadata at
/// signup) and exposes the display content the view renders.
@MainActor
@Observable
final class ProfileViewModel {
    /// Presentation content (stats, highlights, grid) until these are backed by
    /// their own tables. Empty by default so the screen shows real empty states
    /// rather than sample placeholders.
    private(set) var profile: Profile = .empty

    var username = ""
    var displayName = ""
    var bio = ""
    var email = ""
    var avatarURL: URL?

    var isLoading = true
    var isSaving = false
    var isUploadingAvatar = false
    var errorMessage: String?

    /// Storage bucket that holds user avatar images.
    private let avatarBucket = "avatars"

    /// The header/username line, falling back to the email's local part.
    var handle: String {
        if !username.isEmpty { return username }
        if let local = email.split(separator: "@").first { return String(local) }
        return "profile"
    }

    /// The user's display name, empty when unset.
    var name: String {
        displayName
    }

    /// The user's bio/description, empty when unset.
    var displayBio: String {
        bio
    }

    /// Fetches the current user and populates the fields from its metadata.
    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await SupabaseManager.client.auth.user()
            username = user.userMetadata["username"]?.stringValue ?? ""
            displayName = user.userMetadata["full_name"]?.stringValue ?? ""
            bio = user.userMetadata["bio"]?.stringValue ?? ""
            email = user.email ?? ""
            avatarURL = (user.userMetadata["avatar_url"]?.stringValue).flatMap(URL.init(string:))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Persists a new display name and bio to the user's metadata and updates
    /// the local fields on success. No-ops for a blank name or unchanged input.
    func saveProfile(name newName: String, bio newBio: String) async {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = newBio.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        guard trimmedName != displayName || trimmedBio != bio else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let user = try await SupabaseManager.client.auth.update(
                user: UserAttributes(data: [
                    "full_name": .string(trimmedName),
                    "bio": .string(trimmedBio)
                ])
            )
            displayName = user.userMetadata["full_name"]?.stringValue ?? trimmedName
            bio = user.userMetadata["bio"]?.stringValue ?? trimmedBio
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Uploads new avatar image data to the `avatars` bucket (keyed by user id),
    /// stores its public URL in the user's `avatar_url` metadata, and refreshes
    /// the displayed avatar. A cache-busting query item forces `AsyncImage` to
    /// reload after an overwrite.
    func uploadAvatar(_ data: Data) async {
        isUploadingAvatar = true
        defer { isUploadingAvatar = false }

        do {
            let client = SupabaseManager.client
            let userID = try await client.auth.user().id
            let path = "\(userID.uuidString)/avatar.jpg"

            try await client.storage
                .from(avatarBucket)
                .upload(
                    path,
                    data: data,
                    options: FileOptions(contentType: "image/jpeg", upsert: true)
                )

            let publicURL = try client.storage.from(avatarBucket).getPublicURL(path: path)

            let user = try await client.auth.update(
                user: UserAttributes(data: ["avatar_url": .string(publicURL.absoluteString)])
            )

            let stored = (user.userMetadata["avatar_url"]?.stringValue).flatMap(URL.init(string:)) ?? publicURL
            avatarURL = cacheBusted(stored)
        } catch {
            errorMessage = error.localizedDescription
            #if DEBUG
            debugPrint("Error uploading avatar: \(error)")
            #endif
        }
    }

    /// Signs the current user out. The root view observes the resulting
    /// auth-state change and routes back to the sign-up flow.
    ///
    /// A `.global` sign-out revokes the session on the Supabase server and
    /// clears the locally stored session (keychain). If that fails (e.g. the
    /// device is offline or the session already expired), we still force a
    /// `.local` sign-out so the user is logged out on this device.
    func signOut() async {
        do {
            try await SupabaseManager.client.auth.signOut(scope: .global)
        } catch {
            errorMessage = error.localizedDescription
            try? await SupabaseManager.client.auth.signOut(scope: .local)
        }
    }

    /// Appends a timestamp query item so an overwritten image at the same URL is
    /// re-fetched instead of served from cache.
    private func cacheBusted(_ url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: "t", value: UUID().uuidString))
        components.queryItems = items
        return components.url ?? url
    }
}

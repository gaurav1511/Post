import Foundation
import Supabase

/// Tracks the app-wide authentication state so the root view can route the user
/// to the home screen whenever there is an active session.
@MainActor
@Observable
final class AuthViewModel {
    /// Whether a signed-in session currently exists.
    var isLoggedIn = false

    /// True until the initial session has been resolved, so the UI can show a
    /// splash instead of briefly flashing the sign-up screen on launch.
    var isResolving = true

    /// Marks whether the app has launched at least once on this install. The
    /// keychain-backed session survives app deletion, so this UserDefaults flag
    /// (which does not) lets us detect a fresh install and clear the leftover.
    private static let hasLaunchedKey = "com.grain.hasLaunchedBefore"

    init() {
        // Seed from any persisted, still-valid session so the first render is
        // correct. An expired session is treated as logged-out.
        isLoggedIn = Self.isActive(SupabaseManager.client.auth.currentSession)
    }

    /// Observes Supabase auth-state changes for the lifetime of the app.
    /// An `.initialSession` event is always emitted first.
    func observe() async {
        await clearLeftoverSessionOnFreshInstall()

        for await (event, session) in SupabaseManager.client.auth.authStateChanges {
            switch event {
            case .initialSession:
                isLoggedIn = Self.isActive(session)
                isResolving = false
            case .signedIn, .tokenRefreshed, .userUpdated:
                isLoggedIn = Self.isActive(session)
            case .signedOut:
                isLoggedIn = false
            default:
                break
            }
        }
    }

    /// A session counts as active only when it exists and hasn't expired, so a
    /// stale token doesn't route the user into the signed-in experience.
    private static func isActive(_ session: Session?) -> Bool {
        guard let session else { return false }
        return !session.isExpired
    }

    /// On the first launch after a fresh (re)install, clears any session left
    /// behind in the keychain so deleting the app effectively signs the user
    /// out. No-ops on every subsequent launch.
    private func clearLeftoverSessionOnFreshInstall() async {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: Self.hasLaunchedKey) else { return }
        defaults.set(true, forKey: Self.hasLaunchedKey)

        if SupabaseManager.client.auth.currentSession != nil {
            try? await SupabaseManager.client.auth.signOut(scope: .local)
            isLoggedIn = false
        }
    }
}

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

    init() {
        // Seed from any persisted session so the first render is correct.
        isLoggedIn = SupabaseManager.client.auth.currentSession != nil
    }

    /// Observes Supabase auth-state changes for the lifetime of the app.
    /// An `.initialSession` event is always emitted first.
    func observe() async {
        for await (event, session) in SupabaseManager.client.auth.authStateChanges {
            switch event {
            case .initialSession:
                isLoggedIn = session != nil
                isResolving = false
            case .signedIn, .tokenRefreshed, .userUpdated:
                isLoggedIn = session != nil
            case .signedOut:
                isLoggedIn = false
            default:
                break
            }
        }
    }
}

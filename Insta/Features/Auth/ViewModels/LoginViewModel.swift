import Foundation
import Supabase

/// Drives the login form and performs sign-in against Supabase Auth.
@MainActor
@Observable
final class LoginViewModel {
    var email = ""
    var password = ""
    var showPassword = false

    var isSubmitting = false
    var errorMessage: String?
    var didSignIn = false

    /// Whether the form is complete enough to submit.
    var canSubmit: Bool {
        !email.isEmpty
            && !password.isEmpty
            && !isSubmitting
    }

    /// Signs the user in via Supabase Auth. Errors are surfaced through `errorMessage`.
    func logIn() async {
        errorMessage = nil

        guard email.isValidEmail else {
            errorMessage = "Please enter a valid email address."
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await SupabaseManager.client.auth.signIn(
                email: email,
                password: password
            )
            didSignIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

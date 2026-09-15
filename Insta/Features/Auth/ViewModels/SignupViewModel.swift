import Foundation
import Supabase

/// Drives the signup form and performs account creation against Supabase Auth.
@MainActor
@Observable
final class SignupViewModel {
    var fullName = ""
    var username = ""
    var email = ""
    var password = ""
    var showPassword = false
    var agreedToTerms = false

    var isSubmitting = false
    var errorMessage: String?
    var didSignUp = false

    /// Whether the form is complete enough to submit.
    var canSubmit: Bool {
        !fullName.isEmpty
            && !username.isEmpty
            && !email.isEmpty
            && !password.isEmpty
            && agreedToTerms
            && !isSubmitting
    }

    /// Creates the account via Supabase Auth, attaching the name and username
    /// as user metadata. Errors are surfaced through `errorMessage`.
    func signUp() async {
        errorMessage = nil

        guard agreedToTerms else {
            errorMessage = "Please agree to the Terms and Privacy Policy to continue."
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await SupabaseManager.client.auth.signUp(
                email: email,
                password: password,
                data: [
                    "full_name": .string(fullName),
                    "username": .string(username)
                ]
            )
            didSignUp = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

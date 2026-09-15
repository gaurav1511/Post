import SwiftUI

// MARK: - Login Screen

/// Sign-in screen matching the "GRAIN" signup styling, backed by Supabase Auth.
struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @State private var showSignup = false

    var body: some View {
        NavigationStack {
            ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                heading

                SignupField(
                    label: "EMAIL",
                    systemIcon: "envelope",
                    placeholder: "you@example.com",
                    text: $viewModel.email,
                    keyboardType: .emailAddress
                )

                passwordField

                Text("Forgot password?")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Color.grainCoral)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                LoginButton(
                    title: "Log in",
                    isLoading: viewModel.isSubmitting,
                    isEnabled: viewModel.canSubmit
                ) {
                    Task { await viewModel.logIn() }
                }
                .padding(.top, 4)

                footer
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(Color.grainBackground)
        .preferredColorScheme(.dark)
        .alert(
            "Couldn't log in",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
            .navigationDestination(isPresented: $showSignup) {
                SignupView()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: Sections

    private var header: some View {
        HStack {
            Spacer()
            Text("GRAIN")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.grainLabel)
        }
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome back")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.grainTextPrimary)
            Text("Log in to pick up where you left off.")
                .font(.system(size: 13))
                .foregroundStyle(Color.grainTextMuted)
        }
    }

    private var passwordField: some View {
        SignupField(
            label: "PASSWORD",
            systemIcon: "lock",
            placeholder: "Your password",
            text: $viewModel.password,
            isSecure: !viewModel.showPassword
        ) {
            Button {
                viewModel.showPassword.toggle()
            } label: {
                Text(viewModel.showPassword ? "Hide" : "Show")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Color.grainCoral)
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .foregroundStyle(Color.grainTextMuted)
            Button {
                showSignup = true
            } label: {
                Text("Sign up")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.grainCoral)
            }
        }
        .font(.system(size: 13))
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LoginView()
}

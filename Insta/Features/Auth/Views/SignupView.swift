import SwiftUI

// MARK: - Signup Screen

/// Recreation of the Figma "10-signup" screen (Step 1 of 3), backed by Supabase Auth.
struct SignupView: View {
    @State private var viewModel = SignupViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                progress
                heading

                SignupField(
                    label: "FULL NAME",
                    systemIcon: "person",
                    placeholder: "Your name",
                    text: $viewModel.fullName
                )

                SignupField(
                    label: "USERNAME",
                    systemIcon: "tag",
                    placeholder: "username",
                    text: $viewModel.username,
                    borderColor: viewModel.username.isEmpty ? .grainBorder : .grainGreen
                ) {
                    if !viewModel.username.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.grainGreen)
                            Text("Available")
                                .font(.system(size: 11.5, weight: .bold))
                                .foregroundStyle(Color.grainGreen)
                        }
                    }
                }

                SignupField(
                    label: "EMAIL",
                    systemIcon: "envelope",
                    placeholder: "you@example.com",
                    text: $viewModel.email,
                    borderColor: .grainCoral,
                    keyboardType: .emailAddress
                )

                passwordField
                passwordStrength
                consent

                LoginButton(
                    title: "Create account",
                    isLoading: viewModel.isSubmitting,
                    isEnabled: viewModel.canSubmit
                ) {
                    Task { await viewModel.signUp() }
                }
                .padding(.top, 4)

                footer
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(Color.grainBackground)
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert(
            "Couldn't create account",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Account created", isPresented: $viewModel.didSignUp) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("Check your email to confirm your address.")
        }
    }

    // MARK: Sections

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.grainTextPrimary)
            }
            Spacer()
            Text("GRAIN")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.grainLabel)
        }
    }

    private var progress: some View {
        VStack(alignment: .leading, spacing: 10) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.grainField)
                    Capsule().fill(Color.grainCoral)
                        .frame(width: geo.size.width / 3)
                }
            }
            .frame(height: 4)

            Text("STEP 1 OF 3")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.grainLabel)
        }
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Create your account")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.grainTextPrimary)
            Text("Takes about a minute. No feed until you follow someone.")
                .font(.system(size: 13))
                .foregroundStyle(Color.grainTextMuted)
        }
    }

    private var passwordField: some View {
        SignupField(
            label: "PASSWORD",
            systemIcon: "lock",
            placeholder: "Create a password",
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

    @ViewBuilder
    private var passwordStrength: some View {
        if !viewModel.password.isEmpty {
            let strength = viewModel.passwordStrength
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(index < strength.filledBars ? strength.color : Color.grainField)
                            .frame(height: 4)
                    }
                }
                Text(strength.label)
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundStyle(strength.color)
            }
        }
    }

    private var consent: some View {
        HStack(alignment: .top, spacing: 10) {
            Button {
                viewModel.agreedToTerms.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(viewModel.agreedToTerms ? Color.grainCoral : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(viewModel.agreedToTerms ? Color.grainCoral : Color.grainBorder, lineWidth: 1.5)
                    )
                    .frame(width: 20, height: 20)
                    .overlay {
                        if viewModel.agreedToTerms {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
            }

            consentText
        }
    }

    private var consentText: Text {
        let muted = Color.grainTextMuted
        let terms = Text("Terms").foregroundColor(.grainCoral).bold()
        let privacy = Text("Privacy Policy").foregroundColor(.grainCoral).bold()
        return Text("I agree to the \(terms) and \(privacy) and confirm I'm 16 or older")
            .foregroundColor(muted)
    }

    private var footer: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .foregroundStyle(Color.grainTextMuted)
            Button {
                dismiss()
            } label: {
                Text("Log in")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.grainCoral)
            }
        }
        .font(.system(size: 13))
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SignupView()
}

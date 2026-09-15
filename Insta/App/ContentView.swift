import SwiftUI

/// Root view. Routes between the auth flow and the signed-in experience based on
/// the current Supabase session.
struct ContentView: View {
    @State private var auth = AuthViewModel()

    var body: some View {
        Group {
            if auth.isResolving {
                // Splash while the persisted session is resolved on launch.
                ProgressView()
                    .tint(Color.grainCoral)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.grainBackground)
                    .preferredColorScheme(.dark)
            } else if auth.isLoggedIn {
                MainTabView()
            } else {
                SignupView()
            }
        }
        .task { await auth.observe() }
    }
}

#Preview {
    ContentView()
}

import Foundation
import Supabase

/// Shared, app-wide Supabase client.
///
/// Access via `SupabaseManager.client`. Credentials come from `SupabaseConfig`.
enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: SupabaseConfig.projectURL,
        supabaseKey: SupabaseConfig.anonKey,
        options: SupabaseClientOptions(
            auth: SupabaseClientOptions.AuthOptions(
                // Emit the locally stored session immediately as the initial session
                // instead of first attempting a refresh (the SDK's legacy behavior,
                // which triggers a runtime warning). This becomes the default in the
                // next major Supabase release.
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}

import Foundation
import Supabase

/// Shared, app-wide Supabase client.
///
/// Access via `SupabaseManager.client`. Credentials come from `SupabaseConfig`.
enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: SupabaseConfig.projectURL,
        supabaseKey: SupabaseConfig.anonKey
    )
}

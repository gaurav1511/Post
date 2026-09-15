import Foundation

/// Supabase project credentials.
///
/// Fill these in from your Supabase dashboard under **Project Settings ▸ API**.
///
/// The `anon` (public) key is designed to be shipped inside client apps — data
/// access is enforced server-side by Row Level Security policies, so it is not a
/// secret in the way a service-role key is. Do **not** put the service-role key here.
enum SupabaseConfig {
    /// e.g. `https://abcdefghijklmnop.supabase.co`
    static let projectURL = URL(string: "https://yjioigwyurkegkdnxsdi.supabase.co")!

    /// The "anon public" API key from Project Settings ▸ API.
    static let anonKey = "sb_publishable_2pPKYlKjczpjm4OYlpyhsA_AN6EH9yu"
}

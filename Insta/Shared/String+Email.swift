import Foundation

extension String {
    /// Whether the string is a syntactically valid email address.
    ///
    /// Uses a pragmatic pattern (local part, `@`, domain, and a TLD of at least
    /// two letters) — enough to catch obvious typos before hitting the network.
    var isValidEmail: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }
}

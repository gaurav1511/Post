import SwiftUI

/// A qualitative rating of a password, derived from length and character
/// variety, used to drive the signup strength meter.
enum PasswordStrength: Int {
    case empty = 0
    case weak
    case fair
    case good
    case strong

    /// Number of filled segments in the 4-bar meter.
    var filledBars: Int {
        switch self {
        case .empty: return 0
        case .weak: return 1
        case .fair: return 2
        case .good: return 3
        case .strong: return 4
        }
    }

    var label: String {
        switch self {
        case .empty: return ""
        case .weak: return "Weak"
        case .fair: return "Fair"
        case .good: return "Good"
        case .strong: return "Strong"
        }
    }

    var color: Color {
        switch self {
        case .empty: return .grainField
        case .weak: return .grainCoral
        case .fair: return Color(hex: "F5A623")
        case .good: return Color(hex: "F9CE34")
        case .strong: return .grainGreen
        }
    }

    /// Rates `password` by how many strength criteria it satisfies: length ≥ 8,
    /// and the presence of uppercase, lowercase, digit, and symbol characters.
    static func evaluate(_ password: String) -> PasswordStrength {
        guard !password.isEmpty else { return .empty }

        var score = 0
        if password.count >= 8 { score += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[a-z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { score += 1 }

        switch score {
        case 0...1: return .weak
        case 2: return .fair
        case 3: return .good
        default: return .strong
        }
    }
}

extension String {
    /// Whether the password meets the minimum sign-up requirements: at least 8
    /// characters, including at least one letter and one number.
    var meetsPasswordRequirements: Bool {
        count >= 8
            && range(of: "[A-Za-z]", options: .regularExpression) != nil
            && range(of: "[0-9]", options: .regularExpression) != nil
    }
}

import SwiftUI
// MARK: - Design Tokens

/// Color palette pulled from the Figma "10-signup" design.
///
/// Each token is adaptive: it resolves to the dark value in dark mode and a
/// light counterpart in light mode, so the app responds to the user's theme
/// choice. The coral accent is intentionally shared across both schemes.
extension Color {
    static let grainBackground = Color(dark: "0A0A0C", light: "F7F7F5")
    static let grainField = Color(dark: "161619", light: "ECECEA")
    static let grainBorder = Color(dark: "2A2A2E", light: "D8D8D4")
    static let grainCoral = Color(hex: "FF5A3C")
    static let grainTextPrimary = Color(dark: "FAFAF9", light: "111113")
    static let grainTextMuted = Color(dark: "9E9EA6", light: "6B6B72")
    static let grainLabel = Color(dark: "65656C", light: "A6A6AC")
    static let grainGreen = Color(dark: "7CE0B4", light: "1F9D6B")

    /// Builds a color that resolves to `dark` or `light` (hex strings) based on
    /// the active user interface style.
    init(dark: String, light: String) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension Color {
    /// Creates a color from a hex string.
    ///
    /// Supports the following formats (with or without a leading `#`):
    /// - `RGB`     (12-bit, e.g. `"F80"`)
    /// - `RRGGBB`  (24-bit, e.g. `"FF5A3C"`)
    /// - `AARRGGBB` (32-bit with alpha, e.g. `"CCFF5A3C"`)
    ///
    /// Invalid strings fall back to opaque black.
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let a, r, g, b: UInt64
        switch sanitized.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (value >> 8) * 17, (value >> 4 & 0xF) * 17, (value & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (255, value >> 16, value >> 8 & 0xFF, value & 0xFF)
        case 8: // AARRGGBB (32-bit)
            (a, r, g, b) = (value >> 24, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    /// Creates a `UIColor` from a hex string, mirroring `Color(hex:)`.
    convenience init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let a, r, g, b: UInt64
        switch sanitized.count {
        case 3:
            (a, r, g, b) = (255, (value >> 8) * 17, (value >> 4 & 0xF) * 17, (value & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, value >> 16, value >> 8 & 0xFF, value & 0xFF)
        case 8:
            (a, r, g, b) = (value >> 24, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

// MARK: - App Theme

/// The user's selected appearance, persisted across launches.
enum AppTheme: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme {
        self == .dark ? .dark : .light
    }

    var label: String {
        self == .dark ? "Dark" : "Light"
    }
}

import SwiftUI
// MARK: - Design Tokens

/// Color palette pulled from the Figma "10-signup" design.
extension Color {
    static let grainBackground = Color(hex: "0A0A0C")
    static let grainField = Color(hex: "161619")
    static let grainBorder = Color(hex: "2A2A2E")
    static let grainCoral = Color(hex: "FF5A3C")
    static let grainTextPrimary = Color(hex: "FAFAF9")
    static let grainTextMuted = Color(hex: "9E9EA6")
    static let grainLabel = Color(hex: "65656C")
    static let grainGreen = Color(hex: "7CE0B4")
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

import SwiftUI

/// A circular placeholder avatar with a person glyph, matching the design's
/// generic story/profile images.
struct AvatarCircle: View {
    var size: CGFloat

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color(hex: "3A3A40"), Color(hex: "1E1E22")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.5))
                    .foregroundStyle(Color.grainLabel)
            }
    }
}

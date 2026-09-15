import SwiftUI

/// A circular avatar. When `url` is provided the remote image is loaded and
/// clipped to the circle; otherwise it falls back to a person-glyph placeholder
/// matching the design's generic story/profile images.
struct AvatarCircle: View {
    var size: CGFloat
    var url: URL? = nil

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty:
                        placeholder.overlay { ProgressView() }
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var placeholder: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color(hex: "3A3A40"), Color(hex: "1E1E22")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.5))
                    .foregroundStyle(Color.grainLabel)
            }
    }
}

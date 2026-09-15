import SwiftUI
import UIKit
import ImageIO

// MARK: - Image Crop Sheet

/// A square avatar cropper. The user pans and pinch-zooms the source image
/// inside a fixed square window (masked to a circle to preview the avatar
/// shape). Confirming rasterizes the visible square region to JPEG data.
struct ImageCropView: View {
    /// Orientation-normalized, downscaled working copy of the source image.
    private let image: UIImage
    private let onCrop: (Data) -> Void

    init(image: UIImage, onCrop: @escaping (Data) -> Void) {
        self.image = image
        self.onCrop = onCrop
    }

    @Environment(\.dismiss) private var dismiss

    // Committed transform.
    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero

    // In-progress gesture deltas.
    @GestureState private var gestureScale: CGFloat = 1
    @GestureState private var gestureOffset: CGSize = .zero

    /// Longest edge of the exported image, in pixels.
    private let exportPixels: CGFloat = 1024

    private var totalScale: CGFloat { max(scale * gestureScale, 1) }
    private var totalOffset: CGSize {
        CGSize(width: offset.width + gestureOffset.width,
               height: offset.height + gestureOffset.height)
    }

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height) - 48

            ZStack {
                Color.black.ignoresSafeArea()

                croppableImage(side: side)
                    .frame(width: side, height: side)
                    .clipShape(Circle())
                    .overlay {
                        Circle().strokeBorder(.white.opacity(0.9), lineWidth: 2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .gesture(magnification(side: side).simultaneously(with: drag(side: side)))
            }
            .overlay(alignment: .bottom) { controls(side: side) }
            .overlay(alignment: .top) {
                Text("Move and scale")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.top, 16)
            }
        }
    }

    // MARK: Croppable content

    /// The source image laid out to fill the square window with the current
    /// pan/zoom applied. Used both for on-screen display and export.
    private func croppableImage(side: CGFloat) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: side, height: side)
            .scaleEffect(totalScale)
            .offset(totalOffset)
            .frame(width: side, height: side)
            .clipped()
    }

    // MARK: Gestures

    private func magnification(side: CGFloat) -> some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in state = value }
            .onEnded { value in
                scale = max(scale * value, 1)
                offset = clampedOffset(offset, side: side, scale: scale)
            }
    }

    private func drag(side: CGFloat) -> some Gesture {
        DragGesture()
            .updating($gestureOffset) { value, state, _ in state = value.translation }
            .onEnded { value in
                let proposed = CGSize(
                    width: offset.width + value.translation.width,
                    height: offset.height + value.translation.height
                )
                offset = clampedOffset(proposed, side: side, scale: scale)
            }
    }

    /// Constrains the pan offset so the crop window never extends past the
    /// image, which would otherwise bake black edges into the exported avatar.
    private func clampedOffset(_ proposed: CGSize, side: CGFloat, scale: CGFloat) -> CGSize {
        let fillScale = max(side / image.size.width, side / image.size.height)
        let k = fillScale * scale
        let maxX = max(0, (image.size.width * k - side) / 2)
        let maxY = max(0, (image.size.height * k - side) / 2)
        return CGSize(
            width: min(max(proposed.width, -maxX), maxX),
            height: min(max(proposed.height, -maxY), maxY)
        )
    }

    // MARK: Controls

    private func controls(side: CGFloat) -> some View {
        HStack {
            Button("Cancel") { dismiss() }
                .foregroundStyle(.white)

            Spacer()

            Button("Use Photo") {
                if let data = renderCroppedData(side: side) {
                    onCrop(data)
                }
                dismiss()
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color.grainCoral)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 24)
    }

    // MARK: Export

    /// Maps the on-screen square crop window back into source-image pixels and
    /// draws that region into an `exportPixels`-square JPEG using Core Graphics.
    ///
    /// The display lays the image out `scaledToFill` in a `side`-point square
    /// (centered), then applies `scaleEffect` and `offset` about that center.
    /// Inverting that transform gives the crop rect in image space.
    private func renderCroppedData(side: CGFloat) -> Data? {
        let imgW = image.size.width
        let imgH = image.size.height
        guard imgW > 0, imgH > 0 else { return nil }

        // Screen points per image point at the current zoom.
        let fillScale = max(side / imgW, side / imgH)
        let k = fillScale * totalScale
        guard k > 0 else { return nil }

        // The source-image rectangle that fills the square window.
        let cropSide = side / k
        let cropRect = CGRect(
            x: imgW / 2 - (side / 2 + totalOffset.width) / k,
            y: imgH / 2 - (side / 2 + totalOffset.height) / k,
            width: cropSide,
            height: cropSide
        )

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true

        let outputSize = CGSize(width: exportPixels, height: exportPixels)
        let renderer = UIGraphicsImageRenderer(size: outputSize, format: format)

        return renderer.jpegData(withCompressionQuality: 0.85) { context in
            let cg = context.cgContext
            let s = exportPixels / cropRect.width
            cg.scaleBy(x: s, y: s)
            cg.translateBy(x: -cropRect.origin.x, y: -cropRect.origin.y)
            image.draw(at: .zero)
        }
    }
}

// MARK: - UIImage Downsampling

extension UIImage {
    /// Decodes `data` at a reduced size using ImageIO so the full-resolution
    /// pixel buffer is never allocated (large camera photos otherwise trigger
    /// `CVPixelBufferCreate` failures). EXIF orientation is baked in.
    ///
    /// - Parameter maxPixels: Cap for the longest edge, in pixels.
    static func downsampled(from data: Data, maxPixels: CGFloat) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else {
            return nil
        }

        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixels
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

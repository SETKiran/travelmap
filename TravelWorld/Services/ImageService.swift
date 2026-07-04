import SwiftUI

/// Abstraction over where a place's image comes from. Today: remote URLs with a
/// graceful gradient fallback. Later: Unsplash/Pexels search, user uploads, Photos.
protocol ImageService {
    /// Resolve a stored image reference into a loadable URL, if one exists.
    func url(for reference: String?) -> URL?
}

struct RemoteImageService: ImageService {
    func url(for reference: String?) -> URL? {
        guard let reference, !reference.isEmpty else { return nil }
        if reference.hasPrefix("http"), var comps = URLComponents(string: reference) {
            // Ask Unsplash for a reasonably sized crop.
            if comps.host?.contains("unsplash.com") == true {
                comps.queryItems = [
                    .init(name: "auto", value: "format"),
                    .init(name: "fit", value: "crop"),
                    .init(name: "w", value: "1200"),
                    .init(name: "q", value: "80")
                ]
            }
            return comps.url
        }
        return URL(string: reference)
    }
}

/// A deterministic, pleasant gradient derived from a seed string. Used as the
/// placeholder while loading and as the permanent look when no image exists.
struct GradientPlaceholder: View {
    let seed: String

    private var colors: [Color] {
        let hash = abs(seed.hashValue)
        let hue = Double(hash % 360) / 360
        return [
            Color(hue: hue, saturation: 0.45, brightness: 0.78),
            Color(hue: (hue + 0.08).truncatingRemainder(dividingBy: 1), saturation: 0.55, brightness: 0.55)
        ]
    }

    var body: some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(.white.opacity(0.35))
            )
    }
}

/// Drop-in image view that loads a remote reference and always looks intentional.
struct PlaceImage: View {
    let reference: String?
    let seed: String
    var service: ImageService = RemoteImageService()

    var body: some View {
        if let url = service.url(for: reference) {
            AsyncImage(url: url, transaction: Transaction(animation: .easeInOut(duration: 0.4))) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    GradientPlaceholder(seed: seed)
                case .empty:
                    GradientPlaceholder(seed: seed).overlay(ProgressView().tint(.white))
                @unknown default:
                    GradientPlaceholder(seed: seed)
                }
            }
        } else {
            GradientPlaceholder(seed: seed)
        }
    }
}

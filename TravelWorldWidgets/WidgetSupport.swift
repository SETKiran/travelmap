import SwiftUI
import WidgetKit

/// A pleasant gradient derived from a seed string — mirrors the app's placeholder look
/// without any network dependency (widgets render offline).
struct WidgetGradient: View {
    let seed: String

    var body: some View {
        let hash = abs(seed.hashValue)
        let hue = Double(hash % 360) / 360
        LinearGradient(
            colors: [
                Color(hue: hue, saturation: 0.5, brightness: 0.7),
                Color(hue: (hue + 0.08).truncatingRemainder(dividingBy: 1), saturation: 0.6, brightness: 0.45)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}

extension WidgetSnapshot {
    /// Deterministically pick a place to feature, rotating with the given offset.
    func dream(offset: Int) -> Place? {
        guard !dreamPlaces.isEmpty else { return nil }
        return dreamPlaces[offset % dreamPlaces.count]
    }

    func memory(offset: Int) -> Place? {
        guard !visitedPlaces.isEmpty else { return nil }
        return visitedPlaces[offset % visitedPlaces.count]
    }
}

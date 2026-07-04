import SwiftUI
import UIKit

/// A flat equirectangular world map (real continents from a bundled `WorldMap` image),
/// tinted to match the app, with saved & visited places plotted on top. Mapbox-flat look.
///
/// The image is treated as a template (silhouette/coastlines), so any transparent-ocean
/// equirectangular world image works and we control its color.
struct WorldFlatMapView: View {
    var markers: [GlobeMarker]
    var accent: Color = Color(red: 0.20, green: 0.62, blue: 0.53)
    var landColor: Color = .white.opacity(0.55)

    /// Whether the bundled world image is available in this target.
    static var isAvailable: Bool { UIImage(named: "WorldMap") != nil }

    var body: some View {
        GeometryReader { geo in
            let rect = mapRect(in: geo.size)
            ZStack(alignment: .topLeading) {
                Image("WorldMap")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(landColor)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)

                ForEach(Array(markers.enumerated()), id: \.offset) { _, marker in
                    dot(for: marker).position(point(for: marker, in: rect))
                }
            }
        }
    }

    /// Fit a 2:1 equirectangular image inside the available space, centered.
    private func mapRect(in size: CGSize) -> CGRect {
        let aspect: CGFloat = 2
        var w = size.width
        var h = w / aspect
        if h > size.height { h = size.height; w = h * aspect }
        return CGRect(x: (size.width - w) / 2, y: (size.height - h) / 2, width: w, height: h)
    }

    private func point(for m: GlobeMarker, in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + (m.longitude + 180) / 360 * rect.width,
            y: rect.minY + (90 - m.latitude) / 180 * rect.height
        )
    }

    @ViewBuilder private func dot(for m: GlobeMarker) -> some View {
        if m.isVisited {
            Circle().fill(accent)
                .frame(width: 9, height: 9)
                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                .background(Circle().fill(accent.opacity(0.35)).frame(width: 18, height: 18))
        } else {
            Circle().fill(.white.opacity(0.9))
                .frame(width: 6, height: 6)
                .overlay(Circle().stroke(accent.opacity(0.8), lineWidth: 1))
        }
    }
}

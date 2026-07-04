import SwiftUI

/// A single point to plot on the globe.
struct GlobeMarker: Hashable {
    let latitude: Double
    let longitude: Double
    let isVisited: Bool
}

/// A pure-`Canvas` orthographic globe with a latitude/longitude graticule and glowing
/// markers for saved & visited places. No map images, no network — renders offline, so
/// it works identically in the app, the recap, and widgets. Auto-centers on the places
/// so the user's world is always facing the viewer.
struct WorldGlobeView: View {
    var markers: [GlobeMarker]
    /// Degrees of longitude to rotate the globe by — used to gently spin it over time.
    var spinLongitude: Double = 0
    var accent: Color = Color(red: 0.20, green: 0.62, blue: 0.53)
    var oceanTint: Color = Color(red: 0.20, green: 0.62, blue: 0.53)
    var lineColor: Color = .white.opacity(0.16)
    var rimColor: Color = .white.opacity(0.30)

    private var focus: (lat: Double, lon: Double) {
        let visited = markers.filter(\.isVisited)
        let pts = visited.isEmpty ? markers : visited
        guard !pts.isEmpty else { return (20, 10 + spinLongitude) }
        let lat = pts.map(\.latitude).reduce(0, +) / Double(pts.count)
        let sinL = pts.map { sin($0.longitude * .pi / 180) }.reduce(0, +)
        let cosL = pts.map { cos($0.longitude * .pi / 180) }.reduce(0, +)
        let lon = atan2(sinL, cosL) * 180 / .pi
        return (max(-55, min(55, lat)), lon + spinLongitude)
    }

    var body: some View {
        Canvas { ctx, size in
            let radius = min(size.width, size.height) / 2 * 0.94
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let (lat0, lon0) = focus
            let phi0 = lat0 * .pi / 180
            let lam0 = lon0 * .pi / 180

            func project(_ latDeg: Double, _ lonDeg: Double) -> (point: CGPoint, front: Bool) {
                let phi = latDeg * .pi / 180
                let lam = lonDeg * .pi / 180
                let cosc = sin(phi0) * sin(phi) + cos(phi0) * cos(phi) * cos(lam - lam0)
                let x = cos(phi) * sin(lam - lam0)
                let y = cos(phi0) * sin(phi) - sin(phi0) * cos(phi) * cos(lam - lam0)
                return (CGPoint(x: c.x + x * radius, y: c.y - y * radius), cosc >= -0.02)
            }

            // Ocean sphere.
            let globe = Path(ellipseIn: CGRect(x: c.x - radius, y: c.y - radius, width: radius * 2, height: radius * 2))
            ctx.fill(globe, with: .radialGradient(
                Gradient(colors: [oceanTint.opacity(0.30), oceanTint.opacity(0.05)]),
                center: CGPoint(x: c.x - radius * 0.25, y: c.y - radius * 0.25),
                startRadius: 0, endRadius: radius * 1.3))

            // Graticule — parallels (constant latitude) then meridians (constant longitude).
            for lat in stride(from: -60.0, through: 60.0, by: 30.0) {
                var path = Path()
                var drawing = false
                for lon in stride(from: -180.0, through: 180.0, by: 4.0) {
                    let (p, front) = project(lat, lon)
                    if front {
                        drawing ? path.addLine(to: p) : path.move(to: p)
                        drawing = true
                    } else {
                        drawing = false
                    }
                }
                ctx.stroke(path, with: .color(lineColor), lineWidth: 0.75)
            }
            for lon in stride(from: -180.0, through: 150.0, by: 30.0) {
                var path = Path()
                var drawing = false
                for lat in stride(from: -90.0, through: 90.0, by: 4.0) {
                    let (p, front) = project(lat, lon)
                    if front {
                        drawing ? path.addLine(to: p) : path.move(to: p)
                        drawing = true
                    } else {
                        drawing = false
                    }
                }
                ctx.stroke(path, with: .color(lineColor), lineWidth: 0.75)
            }

            ctx.stroke(globe, with: .color(rimColor), lineWidth: 1)

            // Markers — visited glow in accent, dreams as soft white dots.
            for m in markers {
                let (p, front) = project(m.latitude, m.longitude)
                guard front else { continue }
                if m.isVisited {
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - 8, y: p.y - 8, width: 16, height: 16)),
                             with: .color(accent.opacity(0.35)))
                    let core = Path(ellipseIn: CGRect(x: p.x - 3.4, y: p.y - 3.4, width: 6.8, height: 6.8))
                    ctx.fill(core, with: .color(accent))
                    ctx.stroke(core, with: .color(.white.opacity(0.95)), lineWidth: 1)
                } else {
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - 2.4, y: p.y - 2.4, width: 4.8, height: 4.8)),
                             with: .color(.white.opacity(0.6)))
                }
            }
        }
    }
}

#Preview {
    WorldGlobeView(markers: [
        GlobeMarker(latitude: 41.9, longitude: 12.5, isVisited: true),
        GlobeMarker(latitude: 64.1, longitude: -21.9, isVisited: true),
        GlobeMarker(latitude: 35.0, longitude: 135.8, isVisited: false),
        GlobeMarker(latitude: -8.5, longitude: 115.3, isVisited: false)
    ])
    .frame(width: 200, height: 200)
    .padding(40)
    .background(Color.black)
}

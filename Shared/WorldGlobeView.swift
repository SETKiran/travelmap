import SwiftUI

/// A single point to plot on the globe.
struct GlobeMarker: Hashable {
    let latitude: Double
    let longitude: Double
    let isVisited: Bool
}

/// A pure-`Canvas` orthographic globe: dotted continents, an atmosphere glow, arcs
/// between visited places, and glowing markers. No images or network, so it renders
/// identically in the app, the recap and the widget. Auto-centers on the user's places.
struct WorldGlobeView: View {
    var markers: [GlobeMarker]
    /// Degrees of longitude to rotate by — used to gently spin the globe over time.
    var spinLongitude: Double = 0
    var accent: Color = Color(red: 0.20, green: 0.62, blue: 0.53)
    var oceanTint: Color = Color(red: 0.16, green: 0.42, blue: 0.55)
    var landColor: Color = .white
    var lineColor: Color = .white.opacity(0.10)
    var rimColor: Color = .white.opacity(0.30)

    /// Rough continent blobs (center lon/lat + lon/lat radii, in degrees). A point is
    /// "land" if it falls inside any blob — enough to read as Earth without map data.
    private struct Blob { let lon, lat, rx, ry: Double }
    private static let continents: [Blob] = [
        Blob(lon: -100, lat: 48, rx: 32, ry: 20),   // North America
        Blob(lon: -42, lat: 72, rx: 15, ry: 9),     // Greenland
        Blob(lon: -62, lat: -20, rx: 15, ry: 25),   // South America
        Blob(lon: 16, lat: 52, rx: 22, ry: 10),     // Europe
        Blob(lon: 20, lat: 2, rx: 24, ry: 33),      // Africa
        Blob(lon: 100, lat: 50, rx: 55, ry: 22),    // Asia (north)
        Blob(lon: 78, lat: 22, rx: 13, ry: 15),     // India
        Blob(lon: 118, lat: 2, rx: 20, ry: 12),     // SE Asia
        Blob(lon: 134, lat: -25, rx: 18, ry: 12)    // Australia
    ]

    private static func isLand(lat: Double, lon: Double) -> Bool {
        for b in continents {
            var dlon = lon - b.lon
            if dlon > 180 { dlon -= 360 }
            if dlon < -180 { dlon += 360 }
            let nx = dlon / b.rx, ny = (lat - b.lat) / b.ry
            if nx * nx + ny * ny <= 1 { return true }
        }
        return false
    }

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
            let radius = min(size.width, size.height) / 2 * 0.9
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let (lat0, lon0) = focus
            let phi0 = lat0 * .pi / 180
            let lam0 = lon0 * .pi / 180

            func project(_ latDeg: Double, _ lonDeg: Double) -> (point: CGPoint, cosc: Double) {
                let phi = latDeg * .pi / 180
                let lam = lonDeg * .pi / 180
                let cosc = sin(phi0) * sin(phi) + cos(phi0) * cos(phi) * cos(lam - lam0)
                let x = cos(phi) * sin(lam - lam0)
                let y = cos(phi0) * sin(phi) - sin(phi0) * cos(phi) * cos(lam - lam0)
                return (CGPoint(x: c.x + x * radius, y: c.y - y * radius), cosc)
            }

            // Atmosphere glow.
            let glowR = radius * 1.16
            ctx.fill(
                Path(ellipseIn: CGRect(x: c.x - glowR, y: c.y - glowR, width: glowR * 2, height: glowR * 2)),
                with: .radialGradient(
                    Gradient(colors: [accent.opacity(0.28), accent.opacity(0.0)]),
                    center: c, startRadius: radius * 0.85, endRadius: glowR))

            // Ocean sphere with a top-left light source for depth.
            let globe = Path(ellipseIn: CGRect(x: c.x - radius, y: c.y - radius, width: radius * 2, height: radius * 2))
            ctx.fill(globe, with: .radialGradient(
                Gradient(colors: [oceanTint.opacity(0.9), oceanTint.opacity(0.45)]),
                center: CGPoint(x: c.x - radius * 0.3, y: c.y - radius * 0.3),
                startRadius: 0, endRadius: radius * 1.4))

            // Clip everything else to the sphere.
            ctx.clip(to: globe)

            // Faint graticule for curvature.
            for lat in stride(from: -60.0, through: 60.0, by: 30.0) {
                var path = Path(); var drawing = false
                for lon in stride(from: -180.0, through: 180.0, by: 4.0) {
                    let (p, cosc) = project(lat, lon)
                    if cosc >= 0 { drawing ? path.addLine(to: p) : path.move(to: p); drawing = true }
                    else { drawing = false }
                }
                ctx.stroke(path, with: .color(lineColor), lineWidth: 0.6)
            }
            for lon in stride(from: -180.0, through: 150.0, by: 30.0) {
                var path = Path(); var drawing = false
                for lat in stride(from: -90.0, through: 90.0, by: 4.0) {
                    let (p, cosc) = project(lat, lon)
                    if cosc >= 0 { drawing ? path.addLine(to: p) : path.move(to: p); drawing = true }
                    else { drawing = false }
                }
                ctx.stroke(path, with: .color(lineColor), lineWidth: 0.6)
            }

            // Dotted continents on the visible hemisphere.
            let step = 3.5
            for lat in stride(from: -78.0, through: 82.0, by: step) {
                for lon in stride(from: -180.0, through: 180.0, by: step) {
                    guard Self.isLand(lat: lat, lon: lon) else { continue }
                    let (p, cosc) = project(lat, lon)
                    guard cosc >= 0.02 else { continue }
                    let r = 1.15 + cosc * 0.7
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                        with: .color(landColor.opacity(0.30 + cosc * 0.35)))
                }
            }

            // Arcs between visited places (in order), on the visible side.
            let visited = markers.filter(\.isVisited)
            if visited.count > 1 {
                var arc = Path(); var drawing = false
                for m in visited {
                    let (p, cosc) = project(m.latitude, m.longitude)
                    if cosc >= 0 { drawing ? arc.addLine(to: p) : arc.move(to: p); drawing = true }
                    else { drawing = false }
                }
                ctx.stroke(arc, with: .color(accent.opacity(0.5)),
                           style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }

            // Markers.
            for m in markers {
                let (p, cosc) = project(m.latitude, m.longitude)
                guard cosc >= 0 else { continue }
                if m.isVisited {
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - 9, y: p.y - 9, width: 18, height: 18)),
                             with: .color(accent.opacity(0.35)))
                    let core = Path(ellipseIn: CGRect(x: p.x - 3.6, y: p.y - 3.6, width: 7.2, height: 7.2))
                    ctx.fill(core, with: .color(accent))
                    ctx.stroke(core, with: .color(.white.opacity(0.95)), lineWidth: 1.2)
                } else {
                    let dot = Path(ellipseIn: CGRect(x: p.x - 3, y: p.y - 3, width: 6, height: 6))
                    ctx.fill(dot, with: .color(.white.opacity(0.85)))
                    ctx.stroke(dot, with: .color(accent.opacity(0.7)), lineWidth: 1)
                }
            }

            // Rim on top (outside the clip so it stays crisp).
            ctx.stroke(globe, with: .color(rimColor), lineWidth: 1)
        }
    }
}

#Preview {
    WorldGlobeView(markers: [
        GlobeMarker(latitude: 41.9, longitude: 12.5, isVisited: true),
        GlobeMarker(latitude: 64.1, longitude: -21.9, isVisited: true),
        GlobeMarker(latitude: 40.7, longitude: -74.0, isVisited: true),
        GlobeMarker(latitude: 35.0, longitude: 135.8, isVisited: false),
        GlobeMarker(latitude: -8.5, longitude: 115.3, isVisited: false)
    ])
    .frame(width: 240, height: 240)
    .padding(40)
    .background(Color.black)
}

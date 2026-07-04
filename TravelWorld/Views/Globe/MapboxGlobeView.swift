import SwiftUI
// In Mapbox 11.3 the SwiftUI API (Map, Viewport, ForEvery, ViewAnnotation, mapStyle)
// is still experimental SPI. On Xcode 16 + Mapbox 11.5+ this becomes a plain
// `import MapboxMaps`.
@_spi(Experimental) import MapboxMaps

/// The main-screen 3D globe, powered by Mapbox. The Standard style renders as a globe
/// at low zoom; each saved place is a SwiftUI thumbnail marker via a Mapbox view annotation.
struct MapboxGlobeView: View {
    var locations: [Location]
    var selectedID: UUID?
    var onSelect: (Location) -> Void

    @State private var viewport: Viewport = .camera(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 5),
        zoom: 1.15
    )

    var body: some View {
        Map(viewport: $viewport) {
            ForEvery(locations, id: \.uuid) { location in
                ViewAnnotation(coordinate: location.coordinate) {
                    LocationThumbnailMarker(
                        location: location,
                        size: 46,
                        isSelected: selectedID == location.uuid
                    )
                    .onTapGesture { onSelect(location) }
                }
                .allowOverlap(true)
            }
        }
        .mapStyle(.standard)
    }
}

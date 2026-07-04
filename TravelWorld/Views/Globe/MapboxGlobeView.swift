import SwiftUI
import MapboxMaps

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
        .ornamentOptions(OrnamentOptions(
            scaleBar: ScaleBarViewOptions(visibility: .hidden),
            compass: CompassViewOptions(visibility: .hidden),
            logo: LogoViewOptions(margins: CGPoint(x: 8, y: 8)),
            attributionButton: AttributionButtonOptions(margins: CGPoint(x: 8, y: 8))
        ))
    }
}

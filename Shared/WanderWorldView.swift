import SwiftUI

/// Chooses the best available world visualization: the real-continents flat map when a
/// bundled `WorldMap` image exists, otherwise the offline Canvas globe. This lets the app
/// run before the image is added, and upgrades automatically once it is.
struct WanderWorldView: View {
    var markers: [GlobeMarker]
    var spinLongitude: Double = 0

    var body: some View {
        if WorldFlatMapView.isAvailable {
            WorldFlatMapView(markers: markers)
        } else {
            WorldGlobeView(markers: markers, spinLongitude: spinLongitude)
        }
    }
}

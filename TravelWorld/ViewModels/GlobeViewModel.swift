import SwiftUI
import MapKit
import Observation

@Observable
final class GlobeViewModel {
    var cameraPosition: MapCameraPosition = .automatic
    var selectedLocation: Location?
    var isAddingPlace = false

    func select(_ location: Location) {
        Haptics.selection()
        selectedLocation = location
    }

    func frame(on location: Location) {
        withAnimation(.easeInOut) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 12, longitudeDelta: 12)
                )
            )
        }
    }
}

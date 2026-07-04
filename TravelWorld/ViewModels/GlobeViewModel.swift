import SwiftUI
import MapKit
import Observation

@Observable
final class GlobeViewModel {
    var cameraPosition: MapCameraPosition = .automatic
    var selectedLocation: Location?
    var isAddingPlace = false

    func greeting(now: Date = .now) -> String {
        let hour = Calendar.current.component(.hour, from: now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Late night wandering"
        }
    }

    func statLine(for stats: UserStats) -> String {
        "\(stats.placesSaved) places saved · \(stats.placesVisited) visited"
    }

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

import Observation

@Observable
final class GlobeViewModel {
    var selectedLocation: Location?
    var isAddingPlace = false

    func select(_ location: Location) {
        Haptics.selection()
        selectedLocation = location
    }
}

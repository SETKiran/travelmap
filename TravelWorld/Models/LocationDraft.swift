import Foundation

/// A mutable, pre-save representation of a place being added. Decouples the add/confirm
/// UI from the SwiftData model so nothing is persisted until the user taps Save.
struct LocationDraft {
    var name: String = ""
    var region: String = ""
    var country: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var imageURL: String?
    var status: LocationStatus = .wantToVisit
    var source: LocationSource = .manual
    var tags: Set<LocationTag> = []
    var notes: String = ""

    var hasCoordinate: Bool { latitude != 0 || longitude != 0 }
    var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    init() {}

    init(from result: PlaceSearchResult) {
        name = result.name
        region = result.region ?? ""
        country = result.country
        latitude = result.latitude
        longitude = result.longitude
    }

    init(from detected: DetectedPlace) {
        name = detected.name
        region = detected.region ?? ""
        country = detected.country
        latitude = detected.latitude
        longitude = detected.longitude
        imageURL = detected.imageURL
        source = detected.source
        tags = Set(detected.suggestedTags)
    }

    func makeLocation() -> Location {
        Location(
            name: name.trimmingCharacters(in: .whitespaces),
            country: country.trimmingCharacters(in: .whitespaces),
            region: region.isEmpty ? nil : region,
            latitude: latitude,
            longitude: longitude,
            imageURL: imageURL,
            status: status,
            source: source,
            tags: Array(tags),
            visitedDate: status == .visited ? .now : nil,
            notes: notes.isEmpty ? nil : notes
        )
    }
}

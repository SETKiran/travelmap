import Foundation

/// A tiny, Codable projection of the user's world that both the app (writer) and the
/// widgets (reader) understand. Keeps the widget target free of SwiftData.
struct WidgetSnapshot: Codable {
    struct Place: Codable, Identifiable {
        let id: UUID
        let name: String
        let country: String
        let imageURL: String?
        let isVisited: Bool
        var latitude: Double = 0
        var longitude: Double = 0
    }

    var placesSaved: Int
    var placesVisited: Int
    var countriesVisited: Int
    var dreamPlaces: [Place]
    var visitedPlaces: [Place]

    /// All places as globe markers for the world widget / recap globe.
    var globeMarkers: [GlobeMarker] {
        (visitedPlaces + dreamPlaces).map {
            GlobeMarker(latitude: $0.latitude, longitude: $0.longitude, isVisited: $0.isVisited)
        }
    }

    static let empty = WidgetSnapshot(
        placesSaved: 0, placesVisited: 0, countriesVisited: 0, dreamPlaces: [], visitedPlaces: []
    )

    static let placeholder = WidgetSnapshot(
        placesSaved: 42, placesVisited: 12, countriesVisited: 9,
        dreamPlaces: [
            Place(id: UUID(), name: "Kyoto", country: "Japan",
                  imageURL: nil, isVisited: false, latitude: 35.01, longitude: 135.77),
            Place(id: UUID(), name: "Bali", country: "Indonesia",
                  imageURL: nil, isVisited: false, latitude: -8.5, longitude: 115.26)
        ],
        visitedPlaces: [
            Place(id: UUID(), name: "Reykjavik", country: "Iceland",
                  imageURL: nil, isVisited: true, latitude: 64.14, longitude: -21.94),
            Place(id: UUID(), name: "Rome", country: "Italy",
                  imageURL: nil, isVisited: true, latitude: 41.9, longitude: 12.5),
            Place(id: UUID(), name: "Santorini", country: "Greece",
                  imageURL: nil, isVisited: true, latitude: 36.39, longitude: 25.46)
        ]
    )
}

extension WidgetSnapshot.Place {
    private enum CodingKeys: String, CodingKey {
        case id, name, country, imageURL, isVisited, latitude, longitude
    }

    /// Resilient decoding — tolerates older snapshots written before coordinates existed.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        country = try c.decode(String.self, forKey: .country)
        imageURL = try c.decodeIfPresent(String.self, forKey: .imageURL)
        isVisited = try c.decode(Bool.self, forKey: .isVisited)
        latitude = try c.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        longitude = try c.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
    }
}

enum WidgetSnapshotStore {
    static func read() -> WidgetSnapshot? {
        guard let url = AppGroupShared.snapshotURL,
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    static func write(_ snapshot: WidgetSnapshot) {
        guard let url = AppGroupShared.snapshotURL,
              let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: url, options: .atomic)
    }
}

/// Duplicated tiny constant so the shared file has no dependency on the app target.
enum AppGroupShared {
    static let identifier = "group.com.wander.travelworld"
    static var snapshotURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: identifier)?
            .appendingPathComponent("widget-snapshot.json")
    }
}

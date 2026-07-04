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
    }

    var placesSaved: Int
    var placesVisited: Int
    var countriesVisited: Int
    var dreamPlaces: [Place]
    var visitedPlaces: [Place]

    static let placeholder = WidgetSnapshot(
        placesSaved: 42, placesVisited: 12, countriesVisited: 9,
        dreamPlaces: [
            Place(id: UUID(), name: "Kyoto", country: "Japan",
                  imageURL: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e", isVisited: false)
        ],
        visitedPlaces: [
            Place(id: UUID(), name: "Reykjavik", country: "Iceland",
                  imageURL: "https://images.unsplash.com/photo-1504829857797-ddff29c27927", isVisited: true)
        ]
    )
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

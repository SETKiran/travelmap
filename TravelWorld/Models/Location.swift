import Foundation
import SwiftData
import CoreLocation

@Model
final class Location {
    @Attribute(.unique) var uuid: UUID
    var name: String
    var country: String
    var region: String?
    var latitude: Double
    var longitude: Double

    /// Remote or bundled image identifier. Resolved through `ImageService`.
    var imageURL: String?
    /// Locally stored memory photos (file names within the app's documents dir).
    var memoryImageNames: [String]

    private var statusRaw: String
    private var sourceRaw: String
    private var tagsRaw: [String]

    var savedDate: Date
    var visitedDate: Date?
    var notes: String?
    var personalRating: Int?

    /// Optional link back to a Trip. Kept as an id to avoid heavy relationships in the MVP.
    var tripID: UUID?

    init(
        uuid: UUID = UUID(),
        name: String,
        country: String,
        region: String? = nil,
        latitude: Double,
        longitude: Double,
        imageURL: String? = nil,
        memoryImageNames: [String] = [],
        status: LocationStatus = .wantToVisit,
        source: LocationSource = .manual,
        tags: [LocationTag] = [],
        savedDate: Date = .now,
        visitedDate: Date? = nil,
        notes: String? = nil,
        personalRating: Int? = nil,
        tripID: UUID? = nil
    ) {
        self.uuid = uuid
        self.name = name
        self.country = country
        self.region = region
        self.latitude = latitude
        self.longitude = longitude
        self.imageURL = imageURL
        self.memoryImageNames = memoryImageNames
        self.statusRaw = status.rawValue
        self.sourceRaw = source.rawValue
        self.tagsRaw = tags.map(\.rawValue)
        self.savedDate = savedDate
        self.visitedDate = visitedDate
        self.notes = notes
        self.personalRating = personalRating
        self.tripID = tripID
    }
}

// MARK: - Typed accessors over the stored raw values

extension Location {
    var status: LocationStatus {
        get { LocationStatus(rawValue: statusRaw) ?? .wantToVisit }
        set { statusRaw = newValue.rawValue }
    }

    var source: LocationSource {
        get { LocationSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    var tags: [LocationTag] {
        get { tagsRaw.compactMap(LocationTag.init(rawValue:)) }
        set { tagsRaw = newValue.map(\.rawValue) }
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var continent: Continent {
        Continent.of(latitude: latitude, longitude: longitude)
    }

    func markVisited(on date: Date = .now) {
        status = .visited
        if visitedDate == nil { visitedDate = date }
    }
}

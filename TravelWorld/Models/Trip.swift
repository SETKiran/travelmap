import Foundation
import SwiftData

@Model
final class Trip {
    @Attribute(.unique) var uuid: UUID
    var name: String
    var startDate: Date
    var endDate: Date?
    var coverImageURL: String?
    private var sourceRaw: String

    /// Ids of the locations visited on this trip.
    var locationIDs: [UUID]

    init(
        uuid: UUID = UUID(),
        name: String,
        startDate: Date,
        endDate: Date? = nil,
        coverImageURL: String? = nil,
        source: LocationSource = .manual,
        locationIDs: [UUID] = []
    ) {
        self.uuid = uuid
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.coverImageURL = coverImageURL
        self.sourceRaw = source.rawValue
        self.locationIDs = locationIDs
    }

    var source: LocationSource {
        get { LocationSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }
}

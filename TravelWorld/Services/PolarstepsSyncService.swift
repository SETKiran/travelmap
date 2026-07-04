import Foundation

/// A trip that could be imported from Polarsteps, with the places it visited.
struct ImportableTrip: Identifiable {
    let id = UUID()
    let name: String
    let startDate: Date
    let endDate: Date?
    let coverImageURL: String?
    let places: [DetectedPlace]
}

protocol PolarstepsSyncService {
    /// Fetch trips available to import. Nothing is written until the user confirms.
    func availableTrips() async throws -> [ImportableTrip]
}

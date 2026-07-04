import Foundation

/// A visited-place suggestion derived from a photo's location metadata.
/// Privacy-first: the app never uploads photos and never auto-marks anything.
struct PhotoPlaceSuggestion: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    let takenOn: Date
    let thumbnailURL: String?
}

protocol PhotoLocationImportService {
    /// Ask for suggestions the user can review and confirm. Requires photo permission.
    func suggestions() async throws -> [PhotoPlaceSuggestion]
}

/// Placeholder implementation. A real one would use the Photos framework, read
/// `CLLocation` from asset metadata, cluster by place, and reverse-geocode.
struct MockPhotoLocationImportService: PhotoLocationImportService {
    func suggestions() async throws -> [PhotoPlaceSuggestion] {
        try? await Task.sleep(for: .milliseconds(800))
        let cal = Calendar.current
        return [
            PhotoPlaceSuggestion(name: "Lisbon", country: "Portugal",
                                 latitude: 38.7223, longitude: -9.1393,
                                 takenOn: cal.date(byAdding: .day, value: -60, to: .now) ?? .now,
                                 thumbnailURL: "https://images.unsplash.com/photo-1585208798174-6cedd86e019a")
        ]
    }
}

import Foundation

/// The result of parsing a shared social link into a place we can confirm & save.
struct DetectedPlace: Equatable {
    let name: String
    let country: String
    let region: String?
    let latitude: Double
    let longitude: Double
    let imageURL: String?
    let source: LocationSource
    let suggestedTags: [LocationTag]
}

protocol SocialLinkImportService {
    /// Parse a pasted URL and return a place to confirm. Never saves automatically —
    /// the caller always shows a confirmation step (privacy-first).
    func detectPlace(from urlString: String) async throws -> DetectedPlace
}

enum SocialLinkImportError: LocalizedError {
    case unrecognizedLink
    case noLocationFound

    var errorDescription: String? {
        switch self {
        case .unrecognizedLink: return "That link isn't from a supported app yet."
        case .noLocationFound: return "We couldn't find a place in that link."
        }
    }
}

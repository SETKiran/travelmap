import Foundation

/// Mocked social-link detection. Recognises the source from the host and returns a
/// plausible place. Real extraction (metadata / caption parsing / OCR / LLM) can be
/// swapped in behind the same protocol without touching the UI.
struct MockSocialLinkImportService: SocialLinkImportService {

    private let catalog: [DetectedPlace] = [
        DetectedPlace(name: "Bali", country: "Indonesia", region: "Ubud",
                      latitude: -8.5069, longitude: 115.2625,
                      imageURL: "https://images.unsplash.com/photo-1537996194471-e657df975ab4",
                      source: .instagram, suggestedTags: [.beach, .nature, .romantic]),
        DetectedPlace(name: "Kyoto", country: "Japan", region: "Kansai",
                      latitude: 35.0116, longitude: 135.7681,
                      imageURL: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e",
                      source: .tiktok, suggestedTags: [.culture, .city, .food]),
        DetectedPlace(name: "Faroe Islands", country: "Faroe Islands", region: "Vágar",
                      latitude: 62.0, longitude: -7.0,
                      imageURL: "https://images.unsplash.com/photo-1516466723877-e4ec1d736c8a",
                      source: .youtube, suggestedTags: [.nature, .adventure])
    ]

    func detectPlace(from urlString: String) async throws -> DetectedPlace {
        // Simulate a brief network/parse delay for a realistic feel.
        try? await Task.sleep(for: .milliseconds(900))

        let lower = urlString.lowercased()
        guard lower.contains("http") else { throw SocialLinkImportError.unrecognizedLink }

        let source: LocationSource
        if lower.contains("tiktok") { source = .tiktok }
        else if lower.contains("instagram") { source = .instagram }
        else if lower.contains("youtu") { source = .youtube }
        else { throw SocialLinkImportError.unrecognizedLink }

        // Deterministically pick a place for the detected source so the demo feels stable.
        if let match = catalog.first(where: { $0.source == source }) {
            return match
        }
        return catalog[abs(urlString.hashValue) % catalog.count]
    }
}

import Foundation

/// Mocked Polarsteps import. Returns a couple of trips with visited places.
/// Swap for a real export parser / API client behind the same protocol later.
struct MockPolarstepsSyncService: PolarstepsSyncService {
    func availableTrips() async throws -> [ImportableTrip] {
        try? await Task.sleep(for: .milliseconds(1200))
        let cal = Calendar.current
        let now = Date()
        func daysAgo(_ n: Int) -> Date { cal.date(byAdding: .day, value: -n, to: now) ?? now }

        return [
            ImportableTrip(
                name: "Southeast Asia 2025",
                startDate: daysAgo(200), endDate: daysAgo(180),
                coverImageURL: "https://images.unsplash.com/photo-1537996194471-e657df975ab4",
                places: [
                    DetectedPlace(name: "Bali", country: "Indonesia", region: "Ubud",
                                  latitude: -8.5069, longitude: 115.2625,
                                  imageURL: "https://images.unsplash.com/photo-1537996194471-e657df975ab4",
                                  source: .polarsteps, suggestedTags: [.beach, .nature]),
                    DetectedPlace(name: "Chiang Mai", country: "Thailand", region: nil,
                                  latitude: 18.7883, longitude: 98.9853,
                                  imageURL: "https://images.unsplash.com/photo-1552465011-b4e21bf6e79a",
                                  source: .polarsteps, suggestedTags: [.culture, .food])
                ]
            ),
            ImportableTrip(
                name: "Patagonia Trek",
                startDate: daysAgo(520), endDate: daysAgo(500),
                coverImageURL: "https://images.unsplash.com/photo-1533130061792-64b345e4a833",
                places: [
                    DetectedPlace(name: "Torres del Paine", country: "Chile", region: "Magallanes",
                                  latitude: -50.9423, longitude: -73.4068,
                                  imageURL: "https://images.unsplash.com/photo-1533130061792-64b345e4a833",
                                  source: .polarsteps, suggestedTags: [.nature, .adventure])
                ]
            )
        ]
    }
}

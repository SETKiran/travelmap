import Foundation

/// Curated seed data so the world feels alive on first launch.
/// Image URLs point at Unsplash; if any fail to load, `ImageService` renders a
/// deterministic gradient placeholder so the UI never looks broken.
enum SampleData {

    static func makeLocations(now: Date = .now) -> [Location] {
        let cal = Calendar.current
        func daysAgo(_ n: Int) -> Date { cal.date(byAdding: .day, value: -n, to: now) ?? now }

        return [
            Location(
                name: "Petra", country: "Jordan", region: "Ma'an",
                latitude: 30.3285, longitude: 35.4444,
                imageURL: "https://images.unsplash.com/photo-1548786811-dd6e453ccca7",
                status: .wantToVisit, source: .manual,
                tags: [.wonder, .culture, .adventure], savedDate: daysAgo(40),
                notes: "The Rose City carved into stone. Walk the Siq at first light."
            ),
            Location(
                name: "Machu Picchu", country: "Peru", region: "Cusco",
                latitude: -13.1631, longitude: -72.5450,
                imageURL: "https://images.unsplash.com/photo-1526392060635-9d6019884377",
                status: .visited, source: .manual,
                tags: [.wonder, .nature, .adventure],
                savedDate: daysAgo(300), visitedDate: daysAgo(120),
                notes: "The clouds parted for exactly ten minutes. I'll never forget it.",
                personalRating: 5
            ),
            Location(
                name: "Kyoto", country: "Japan", region: "Kansai",
                latitude: 35.0116, longitude: 135.7681,
                imageURL: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e",
                status: .wantToVisit, source: .tiktok,
                tags: [.culture, .city, .food], savedDate: daysAgo(12),
                notes: "Bamboo groves in Arashiyama and quiet temple mornings."
            ),
            Location(
                name: "Rome", country: "Italy", region: "Lazio",
                latitude: 41.9028, longitude: 12.4964,
                imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5",
                status: .visited, source: .manual,
                tags: [.city, .culture, .food],
                savedDate: daysAgo(420), visitedDate: daysAgo(210),
                notes: "Cacio e pepe at midnight. The whole city glows amber.",
                personalRating: 5
            ),
            Location(
                name: "Reykjavik", country: "Iceland", region: "Capital Region",
                latitude: 64.1466, longitude: -21.9426,
                imageURL: "https://images.unsplash.com/photo-1504829857797-ddff29c27927",
                status: .visited, source: .manual,
                tags: [.nature, .adventure],
                savedDate: daysAgo(365), visitedDate: daysAgo(95),
                notes: "Chased the aurora until 3am. Worth every frozen minute.",
                personalRating: 4
            ),
            Location(
                name: "Bali", country: "Indonesia", region: "Ubud",
                latitude: -8.5069, longitude: 115.2625,
                imageURL: "https://images.unsplash.com/photo-1537996194471-e657df975ab4",
                status: .wantToVisit, source: .instagram,
                tags: [.beach, .nature, .romantic], savedDate: daysAgo(8)
            ),
            Location(
                name: "New York City", country: "United States", region: "New York",
                latitude: 40.7128, longitude: -74.0060,
                imageURL: "https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9",
                status: .visited, source: .manual,
                tags: [.city, .food, .culture],
                savedDate: daysAgo(500), visitedDate: daysAgo(340),
                notes: "Bagels, jazz, and the view from the Brooklyn Bridge at dusk.",
                personalRating: 4
            ),
            Location(
                name: "Cape Town", country: "South Africa", region: "Western Cape",
                latitude: -33.9249, longitude: 18.4241,
                imageURL: "https://images.unsplash.com/photo-1580060839134-75a5edca2e99",
                status: .wantToVisit, source: .manual,
                tags: [.nature, .city, .adventure], savedDate: daysAgo(25)
            ),
            Location(
                name: "Banff", country: "Canada", region: "Alberta",
                latitude: 51.1784, longitude: -115.5708,
                imageURL: "https://images.unsplash.com/photo-1561134643-668f9057cce4",
                status: .wantToVisit, source: .youtube,
                tags: [.nature, .adventure], savedDate: daysAgo(3),
                notes: "Lake Louise in that impossible shade of turquoise."
            ),
            Location(
                name: "Santorini", country: "Greece", region: "Cyclades",
                latitude: 36.3932, longitude: 25.4615,
                imageURL: "https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff",
                status: .visited, source: .manual,
                tags: [.beach, .romantic, .city],
                savedDate: daysAgo(600), visitedDate: daysAgo(400),
                notes: "White walls, blue domes, and the slowest sunset in the world.",
                personalRating: 5
            )
        ]
    }

    static func makeTrips(now: Date = .now) -> [Trip] {
        let cal = Calendar.current
        func daysAgo(_ n: Int) -> Date { cal.date(byAdding: .day, value: -n, to: now) ?? now }
        return [
            Trip(
                name: "Iceland Ring Road",
                startDate: daysAgo(100), endDate: daysAgo(90),
                coverImageURL: "https://images.unsplash.com/photo-1504829857797-ddff29c27927",
                source: .polarsteps
            )
        ]
    }
}

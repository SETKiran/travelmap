import Foundation

/// One full-screen story card in the yearly recap.
struct RecapCard: Identifiable {
    enum Kind { case intro, number, photos, globe, statement, personality }

    let id = UUID()
    let kind: Kind
    let headline: String
    var subtitle: String? = nil
    var symbol: String? = nil
    var backgroundImageURL: String? = nil
    var gradientSeed: String
    var bigNumber: Int? = nil
    var imageURLs: [String] = []
    var markers: [GlobeMarker] = []
}

/// The complete recap: an ordered set of story cards plus a shareable summary.
struct Recap {
    let year: Int
    let cards: [RecapCard]
    let stats: UserStats
}

protocol RecapGeneratorService {
    func generate(from locations: [Location], year: Int) -> Recap
}

/// Builds a "Your Year in Places" recap purely from local data.
struct LocalRecapGenerator: RecapGeneratorService {

    func generate(from locations: [Location], year: Int) -> Recap {
        let cal = Calendar.current
        let savedThisYear = locations.filter { cal.component(.year, from: $0.savedDate) == year }
        let visitedThisYear = locations.filter {
            guard let d = $0.visitedDate else { return false }
            return cal.component(.year, from: d) == year
        }
        let stats = UserStats(locations: locations)
        func thumbs(_ list: [Location]) -> [String] { list.compactMap(\.imageURL) }
        let markers = locations.map {
            GlobeMarker(latitude: $0.latitude, longitude: $0.longitude, isVisited: $0.status == .visited)
        }

        var cards: [RecapCard] = []

        cards.append(RecapCard(
            kind: .intro,
            headline: "This year,\nyour world got bigger.",
            subtitle: "Let's look back.",
            symbol: "globe.europe.africa.fill",
            gradientSeed: "intro-\(year)"
        ))

        cards.append(RecapCard(
            kind: .number,
            headline: "dream places saved",
            subtitle: savedThisYear.isEmpty ? "A fresh start." : "Places that caught your eye.",
            symbol: "sparkles",
            gradientSeed: "saved",
            bigNumber: savedThisYear.count,
            imageURLs: Array(thumbs(savedThisYear).prefix(4))
        ))

        cards.append(RecapCard(
            kind: .number,
            headline: "places visited",
            subtitle: "Memories made.",
            symbol: "checkmark.seal.fill",
            gradientSeed: "visited",
            bigNumber: visitedThisYear.count,
            imageURLs: Array(thumbs(visitedThisYear).prefix(4))
        ))

        if !markers.isEmpty {
            cards.append(RecapCard(
                kind: .globe,
                headline: "You've touched\n\(stats.continentsVisited) continents.",
                subtitle: "\(stats.countriesVisited) countries and counting.",
                gradientSeed: "globe",
                markers: markers
            ))
        }

        if let topCountry = mostVisitedCountry(visitedThisYear) {
            cards.append(RecapCard(
                kind: .statement,
                headline: "Your most visited\ncountry was \(topCountry).",
                symbol: "mappin.and.ellipse",
                backgroundImageURL: visitedThisYear.first(where: { $0.country == topCountry })?.imageURL,
                gradientSeed: topCountry
            ))
        }

        let photoStrip = thumbs(visitedThisYear.isEmpty ? savedThisYear : visitedThisYear)
        if photoStrip.count >= 3 {
            cards.append(RecapCard(
                kind: .photos,
                headline: "A year in pictures.",
                gradientSeed: "photos",
                imageURLs: Array(photoStrip.prefix(6))
            ))
        }

        if !stats.topTags.isEmpty {
            let list = stats.topTags.map(\.label.localizedLowercase).joined(separator: ", ")
            cards.append(RecapCard(
                kind: .statement,
                headline: "Your year was mostly:\n\(list).",
                symbol: stats.topTags.first?.symbol ?? "tag",
                gradientSeed: "tags-\(list)"
            ))
        }

        if let furthest = furthestSaved(savedThisYear) {
            cards.append(RecapCard(
                kind: .statement,
                headline: "Your furthest dream\nwas \(furthest.name).",
                subtitle: furthest.country,
                symbol: "airplane",
                backgroundImageURL: furthest.imageURL,
                gradientSeed: "furthest-\(furthest.name)"
            ))
        }

        if let topMemory = visitedThisYear.max(by: { ($0.personalRating ?? 0) < ($1.personalRating ?? 0) }) {
            cards.append(RecapCard(
                kind: .statement,
                headline: "Your top memory\nwas \(topMemory.name).",
                subtitle: topMemory.country,
                symbol: "heart.fill",
                backgroundImageURL: topMemory.imageURL,
                gradientSeed: "memory-\(topMemory.name)"
            ))
        }

        cards.append(RecapCard(
            kind: .personality,
            headline: personality(for: stats),
            subtitle: "Your \(year) travel personality",
            symbol: "person.crop.circle.badge.checkmark",
            gradientSeed: "personality"
        ))

        return Recap(year: year, cards: cards, stats: stats)
    }

    private func mostVisitedCountry(_ locations: [Location]) -> String? {
        let counts = locations.reduce(into: [String: Int]()) { $0[$1.country, default: 0] += 1 }
        return counts.max { $0.value < $1.value }?.key
    }

    private func furthestSaved(_ locations: [Location]) -> Location? {
        let home = (lat: 52.3676, lon: 4.9041)
        return locations.max {
            distance(home.lat, home.lon, $0.latitude, $0.longitude) <
            distance(home.lat, home.lon, $1.latitude, $1.longitude)
        }
    }

    private func distance(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) -> Double {
        let dLat = lat2 - lat1, dLon = lon2 - lon1
        return dLat * dLat + dLon * dLon
    }

    private func personality(for stats: UserStats) -> String {
        switch stats.topTags.first {
        case .some(.wonder), .some(.adventure): return "The Wonder Chaser"
        case .some(.nature): return "The Quiet Explorer"
        case .some(.food): return "The Flavor Seeker"
        case .some(.city): return "The City Wanderer"
        case .some(.beach), .some(.romantic): return "The Slow Traveler"
        case .some(.culture): return "The Culture Collector"
        default: return "The Dreamer"
        }
    }
}

import Foundation

/// One full-screen story card in the yearly recap.
struct RecapCard: Identifiable {
    let id = UUID()
    let headline: String
    let subtitle: String?
    let symbol: String?
    let backgroundImageURL: String?
    let gradientSeed: String
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

        var cards: [RecapCard] = []

        cards.append(RecapCard(
            headline: "This year,\nyour world got bigger.",
            subtitle: "Let's look back.",
            symbol: "globe.europe.africa.fill",
            backgroundImageURL: nil, gradientSeed: "intro-\(year)"
        ))

        cards.append(RecapCard(
            headline: "You saved\n\(savedThisYear.count) dream places.",
            subtitle: savedThisYear.count > 0 ? "Places that caught your eye." : "A fresh start.",
            symbol: "sparkles",
            backgroundImageURL: savedThisYear.first?.imageURL, gradientSeed: "saved"
        ))

        cards.append(RecapCard(
            headline: "You visited\n\(visitedThisYear.count) places.",
            subtitle: "Memories made.",
            symbol: "checkmark.seal.fill",
            backgroundImageURL: visitedThisYear.first?.imageURL, gradientSeed: "visited"
        ))

        if let topCountry = mostVisitedCountry(visitedThisYear) {
            cards.append(RecapCard(
                headline: "Your most visited\ncountry was \(topCountry).",
                subtitle: nil, symbol: "mappin.and.ellipse",
                backgroundImageURL: visitedThisYear.first(where: { $0.country == topCountry })?.imageURL,
                gradientSeed: topCountry
            ))
        }

        if !stats.topTags.isEmpty {
            let list = stats.topTags.map(\.label.localizedLowercase).joined(separator: ", ")
            cards.append(RecapCard(
                headline: "Your year was mostly:\n\(list).",
                subtitle: nil, symbol: stats.topTags.first?.symbol ?? "tag",
                backgroundImageURL: nil, gradientSeed: "tags-\(list)"
            ))
        }

        if let furthest = furthestSaved(savedThisYear) {
            cards.append(RecapCard(
                headline: "Your furthest dream\nwas \(furthest.name).",
                subtitle: furthest.country, symbol: "airplane",
                backgroundImageURL: furthest.imageURL, gradientSeed: "furthest-\(furthest.name)"
            ))
        }

        if let topMemory = visitedThisYear.max(by: { ($0.personalRating ?? 0) < ($1.personalRating ?? 0) }) {
            cards.append(RecapCard(
                headline: "Your top memory\nwas \(topMemory.name).",
                subtitle: topMemory.country, symbol: "heart.fill",
                backgroundImageURL: topMemory.imageURL, gradientSeed: "memory-\(topMemory.name)"
            ))
        }

        cards.append(RecapCard(
            headline: "Your \(year) travel personality:\n\(personality(for: stats)).",
            subtitle: nil, symbol: "person.crop.circle.badge.checkmark",
            backgroundImageURL: nil, gradientSeed: "personality"
        ))

        return Recap(year: year, cards: cards, stats: stats)
    }

    private func mostVisitedCountry(_ locations: [Location]) -> String? {
        let counts = locations.reduce(into: [String: Int]()) { $0[$1.country, default: 0] += 1 }
        return counts.max { $0.value < $1.value }?.key
    }

    private func furthestSaved(_ locations: [Location]) -> Location? {
        // Furthest from a rough home anchor (Amsterdam) — a stand-in until we know the user's home.
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

import Foundation

/// A computed, read-only summary of the user's world. Derived from `[Location]` on demand.
struct UserStats {
    var placesSaved: Int
    var placesVisited: Int
    var countriesVisited: Int
    var continentsVisited: Int
    var topTags: [LocationTag]

    static let empty = UserStats(
        placesSaved: 0, placesVisited: 0, countriesVisited: 0, continentsVisited: 0, topTags: []
    )

    init(placesSaved: Int, placesVisited: Int, countriesVisited: Int, continentsVisited: Int, topTags: [LocationTag]) {
        self.placesSaved = placesSaved
        self.placesVisited = placesVisited
        self.countriesVisited = countriesVisited
        self.continentsVisited = continentsVisited
        self.topTags = topTags
    }

    init(locations: [Location]) {
        let visited = locations.filter { $0.status == .visited }
        placesSaved = locations.count
        placesVisited = visited.count
        countriesVisited = Set(visited.map(\.country)).count
        continentsVisited = Set(visited.map(\.continent)).count

        let tagCounts = locations
            .flatMap(\.tags)
            .reduce(into: [LocationTag: Int]()) { $0[$1, default: 0] += 1 }
        topTags = tagCounts.sorted { $0.value > $1.value }.prefix(3).map(\.key)
    }
}

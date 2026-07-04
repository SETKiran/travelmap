import Foundation
import Observation

@Observable
final class PlacesViewModel {
    enum Scope: String, CaseIterable, Identifiable {
        case wantToVisit = "Want to Visit"
        case visited = "Visited"
        case all = "All"
        var id: String { rawValue }
    }

    var scope: Scope = .all
    var searchText = ""
    var selectedTag: LocationTag?

    func filter(_ locations: [Location]) -> [Location] {
        locations.filter { location in
            switch scope {
            case .wantToVisit where location.status != .wantToVisit: return false
            case .visited where location.status != .visited: return false
            default: break
            }

            if let tag = selectedTag, !location.tags.contains(tag) { return false }

            let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
            guard !query.isEmpty else { return true }
            return location.name.lowercased().contains(query)
                || location.country.lowercased().contains(query)
                || (location.region?.lowercased().contains(query) ?? false)
        }
    }

    /// Tags actually present in the data, so the filter row never shows empty options.
    func availableTags(_ locations: [Location]) -> [LocationTag] {
        let present = Set(locations.flatMap(\.tags))
        return LocationTag.allCases.filter(present.contains)
    }
}

import Foundation

enum Continent: String, CaseIterable, Identifiable {
    case africa = "Africa"
    case asia = "Asia"
    case europe = "Europe"
    case northAmerica = "North America"
    case southAmerica = "South America"
    case oceania = "Oceania"
    case antarctica = "Antarctica"

    var id: String { rawValue }

    /// A deliberately rough bounding-box classification — good enough for stats and recap,
    /// with no dependency on a geocoding round-trip.
    static func of(latitude lat: Double, longitude lon: Double) -> Continent {
        switch (lat, lon) {
        case let (la, _) where la < -60: return .antarctica
        case let (la, lo) where la >= -35 && la <= 37 && lo >= -20 && lo <= 52: return .africa
        case let (la, lo) where la >= 35 && lo >= -12 && lo <= 45: return .europe
        case let (_, lo) where lo >= 45 && lo <= 180 && lat >= -10: return .asia
        case let (la, lo) where la <= 0 && lo >= 110: return .oceania
        case let (la, _) where la >= 12: return .northAmerica
        default: return .southAmerica
        }
    }
}

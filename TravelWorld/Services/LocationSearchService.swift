import Foundation
import MapKit

/// A place returned by search, normalized into the fields we care about.
struct PlaceSearchResult: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let country: String
    let region: String?
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

protocol LocationSearchService {
    func search(_ query: String) async throws -> [PlaceSearchResult]
}

/// MapKit-backed local search. Filters to points of interest and addresses.
struct MapKitSearchService: LocationSearchService {
    func search(_ query: String) async throws -> [PlaceSearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return [] }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.resultTypes = [.pointOfInterest, .address]

        let response = try await MKLocalSearch(request: request).start()
        return response.mapItems.compactMap { item in
            let placemark = item.placemark
            let coordinate = placemark.coordinate
            let name = item.name ?? placemark.name ?? trimmed
            return PlaceSearchResult(
                name: name,
                country: placemark.country ?? "",
                region: placemark.locality ?? placemark.administrativeArea,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        }
    }
}

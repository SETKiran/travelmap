import Foundation
import SwiftData
import Observation

@Observable
final class ProfileViewModel {
    func exportJSON(_ locations: [Location]) -> String {
        struct Export: Codable {
            let name: String, country: String, status: String
            let latitude: Double, longitude: Double, savedDate: Date
        }
        let payload = locations.map {
            Export(name: $0.name, country: $0.country, status: $0.status.rawValue,
                   latitude: $0.latitude, longitude: $0.longitude, savedDate: $0.savedDate)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return (try? encoder.encode(payload)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}

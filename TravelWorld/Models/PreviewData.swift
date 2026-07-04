import Foundation
import SwiftData

/// In-memory SwiftData container seeded with sample places, for SwiftUI previews.
enum PreviewData {
    @MainActor static let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Location.self, Trip.self, configurations: config)
        let context = container.mainContext
        SampleData.makeLocations().forEach(context.insert)
        SampleData.makeTrips().forEach(context.insert)
        return container
    }()

    @MainActor static var sampleLocation: Location {
        SampleData.makeLocations().first { $0.status == .visited } ?? SampleData.makeLocations()[0]
    }
}

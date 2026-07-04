import Foundation
import SwiftData
import Observation
import WidgetKit

/// Global, injectable container for services and cross-cutting app state.
/// Services are protocol-typed so mocks can be replaced with real ones in one place.
@Observable
final class AppState {
    // Services
    let searchService: LocationSearchService
    let imageService: ImageService
    let socialImport: SocialLinkImportService
    let polarsteps: PolarstepsSyncService
    let photoImport: PhotoLocationImportService
    let recapGenerator: RecapGeneratorService

    // Preferences (persisted lightly via UserDefaults)
    var iCloudSyncEnabled: Bool {
        didSet { UserDefaults.standard.set(iCloudSyncEnabled, forKey: "iCloudSyncEnabled") }
    }

    init(
        searchService: LocationSearchService = MapKitSearchService(),
        imageService: ImageService = RemoteImageService(),
        socialImport: SocialLinkImportService = MockSocialLinkImportService(),
        polarsteps: PolarstepsSyncService = MockPolarstepsSyncService(),
        photoImport: PhotoLocationImportService = MockPhotoLocationImportService(),
        recapGenerator: RecapGeneratorService = LocalRecapGenerator()
    ) {
        self.searchService = searchService
        self.imageService = imageService
        self.socialImport = socialImport
        self.polarsteps = polarsteps
        self.photoImport = photoImport
        self.recapGenerator = recapGenerator
        self.iCloudSyncEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
    }

    // MARK: Seeding

    /// Seed sample places once, so a brand-new install feels alive immediately.
    func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Location>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        SampleData.makeLocations().forEach(context.insert)
        SampleData.makeTrips().forEach(context.insert)
        try? context.save()
    }

    // MARK: Widget snapshot

    /// Publish a compact snapshot to the App Group and refresh widget timelines.
    func refreshWidgetSnapshot(with locations: [Location]) {
        func project(_ l: Location) -> WidgetSnapshot.Place {
            .init(id: l.uuid, name: l.name, country: l.country,
                  imageURL: l.imageURL, isVisited: l.status == .visited,
                  latitude: l.latitude, longitude: l.longitude)
        }
        let stats = UserStats(locations: locations)
        let snapshot = WidgetSnapshot(
            placesSaved: stats.placesSaved,
            placesVisited: stats.placesVisited,
            countriesVisited: stats.countriesVisited,
            dreamPlaces: locations.filter { $0.status == .wantToVisit }.map(project),
            visitedPlaces: locations.filter { $0.status == .visited }.map(project)
        )
        WidgetSnapshotStore.write(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

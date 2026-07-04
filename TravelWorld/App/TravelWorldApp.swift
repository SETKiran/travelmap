import SwiftUI
import SwiftData
import MapboxMaps

@main
struct TravelWorldApp: App {
    @State private var appState = AppState()

    init() {
        if MapboxConfig.isConfigured {
            MapboxOptions.accessToken = MapboxConfig.accessToken
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .tint(AppTheme.Colors.accent)
        }
        .modelContainer(for: [Location.self, Trip.self])
    }
}

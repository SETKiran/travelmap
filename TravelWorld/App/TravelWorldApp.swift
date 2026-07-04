import SwiftUI
import SwiftData

@main
struct TravelWorldApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .tint(AppTheme.Colors.accent)
        }
        .modelContainer(for: [Location.self, Trip.self])
    }
}

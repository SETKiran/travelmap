import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @Query private var locations: [Location]

    @State private var selection: Tab = .globe

    enum Tab: Hashable { case globe, places, recap, profile }

    /// Changes whenever a place is added, removed, or has its visited status flipped —
    /// the cases that should refresh the widget snapshot.
    private var snapshotSignature: [String] {
        locations.map { "\($0.uuid.uuidString)-\($0.status.rawValue)" }
    }

    var body: some View {
        TabView(selection: $selection) {
            GlobeMapView()
                .tabItem { Label("World", systemImage: "globe.europe.africa.fill") }
                .tag(Tab.globe)

            PlacesView()
                .tabItem { Label("Places", systemImage: "square.grid.2x2.fill") }
                .tag(Tab.places)

            PassportView()
                .tabItem { Label("Passport", systemImage: "book.closed.fill") }
                .tag(Tab.recap)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(Tab.profile)
        }
        .task {
            appState.seedIfNeeded(context: context)
        }
        .onChange(of: snapshotSignature) {
            appState.refreshWidgetSnapshot(with: locations)
        }
        .onAppear {
            appState.refreshWidgetSnapshot(with: locations)
        }
    }
}

#Preview {
    RootView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
}

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Query private var locations: [Location]
    @State private var model = ProfileViewModel()

    private var stats: UserStats { UserStats(locations: locations) }

    var body: some View {
        @Bindable var appState = appState
        NavigationStack {
            List {
                Section { statsHeader }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)

                Section("Sync") {
                    Toggle(isOn: $appState.iCloudSyncEnabled) {
                        Label("iCloud Sync", systemImage: "icloud")
                    }
                    NavigationLink {
                        DataExportView(json: model.exportJSON(locations))
                    } label: {
                        Label("Import / Export data", systemImage: "square.and.arrow.up.on.square")
                    }
                }

                Section("Integrations") {
                    NavigationLink {
                        PolarstepsSyncView()
                    } label: {
                        Label("Polarsteps", systemImage: "figure.walk")
                    }
                    NavigationLink {
                        InfoTextView(title: "Social Links",
                                     body: "Paste a TikTok, Instagram or YouTube link when adding a place and Wander detects the location for you to confirm. Automatic detection is mocked today and will use link metadata and on-device parsing later.")
                    } label: {
                        Label("Social links", systemImage: "link")
                    }
                    NavigationLink {
                        InfoTextView(title: "Apple Photos",
                                     body: "In a future update Wander can suggest visited places from photos that have location data. Photos never leave your device, and you confirm every place before it's added.")
                    } label: {
                        Label("Apple Photos", systemImage: "photo.on.rectangle")
                    }
                }

                Section("App") {
                    NavigationLink {
                        InfoTextView(title: "Widgets",
                                     body: "Add a Wander widget from your Home Screen: touch and hold the background, tap +, search for Wander, then choose Dream Place, Memory or Stats. Widgets update automatically as your world grows.")
                    } label: {
                        Label("Widgets", systemImage: "square.grid.2x2")
                    }
                    NavigationLink {
                        InfoTextView(title: "Privacy",
                                     body: "Wander is local-first. Your places live on your device. Nothing is tracked in the background, and no place is ever marked visited without you. Imports from photos or Polarsteps always require your confirmation.")
                    } label: {
                        Label("Privacy", systemImage: "hand.raised")
                    }
                    HStack {
                        Label("Appearance", systemImage: "circle.lefthalf.filled")
                        Spacer()
                        Text("System").foregroundStyle(.secondary)
                    }
                }

                Section {
                    NavigationLink {
                        TravelPlusView()
                    } label: {
                        Label {
                            Text("Travel Plus")
                        } icon: {
                            Image(systemName: "sparkles").foregroundStyle(.yellow)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Version"); Spacer()
                        Text("1.0").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }

    private var statsHeader: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.md) {
                statTile("\(stats.countriesVisited)", "Countries")
                statTile("\(stats.placesVisited)", "Visited")
                statTile("\(stats.placesSaved)", "Saved")
                statTile("\(stats.continentsVisited)", "Continents")
            }
        }
        .padding(AppTheme.Spacing.md)
    }

    private func statTile(_ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.weight(.bold)).foregroundStyle(AppTheme.Colors.accent)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .fill(AppTheme.Colors.secondaryBackground)
        )
    }
}

struct InfoTextView: View {
    let title: String
    let body_: String
    init(title: String, body: String) { self.title = title; self.body_ = body }

    var body: some View {
        ScrollView {
            Text(body_)
                .font(.body)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataExportView: View {
    let json: String
    var body: some View {
        ScrollView {
            Text(json).font(.system(.footnote, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading).padding()
        }
        .navigationTitle("Export")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: json) { Image(systemName: "square.and.arrow.up") }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
}

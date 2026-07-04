import SwiftUI
import SwiftData

struct GlobeMapView: View {
    @Query(sort: \Location.savedDate, order: .reverse) private var locations: [Location]
    @State private var model = GlobeViewModel()

    private var stats: UserStats { UserStats(locations: locations) }

    var body: some View {
        ZStack(alignment: .top) {
            mapLayer
                .ignoresSafeArea()

            header
        }
        .overlay(alignment: .bottomTrailing) { addButton }
        .overlay { if locations.isEmpty { emptyState } }
        .sheet(item: $model.selectedLocation) { location in
            LocationDetailSheet(location: location)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
        }
        .sheet(isPresented: $model.isAddingPlace) {
            AddLocationView()
        }
    }

    // MARK: Map

    @ViewBuilder private var mapLayer: some View {
        if MapboxConfig.isConfigured {
            MapboxGlobeView(
                locations: locations,
                selectedID: model.selectedLocation?.uuid,
                onSelect: { model.select($0) }
            )
        } else {
            mapboxSetupNotice
        }
    }

    private var mapboxSetupNotice: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.06, green: 0.12, blue: 0.16),
                                    Color(red: 0.10, green: 0.20, blue: 0.22)],
                           startPoint: .top, endPoint: .bottom)
            WanderWorldView(markers: locations.map {
                GlobeMarker(latitude: $0.latitude, longitude: $0.longitude, isVisited: $0.status == .visited)
            })
            .frame(width: 300, height: 260)
            VStack {
                Spacer()
                Text("Add your Mapbox token in MapboxConfig.swift to enable the live globe.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.bottom, 80)
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Text("Your World")
                .font(.title2.weight(.bold))
            Spacer(minLength: 0)
            if !locations.isEmpty {
                HStack(spacing: 12) {
                    statChip(symbol: "sparkles", value: stats.placesSaved, tint: AppTheme.Colors.wantToVisit)
                    statChip(symbol: "checkmark.seal.fill", value: stats.placesVisited, tint: AppTheme.Colors.visited)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, 10)
        .background(Capsule().fill(.regularMaterial).appShadow())
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.sm)
    }

    private func statChip(symbol: String, value: Int, tint: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol).font(.caption).foregroundStyle(tint)
            Text("\(value)").font(.subheadline.weight(.semibold))
        }
    }

    // MARK: Add button

    private var addButton: some View {
        Button {
            Haptics.light()
            model.isAddingPlace = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Circle().fill(AppTheme.Colors.accent))
                .appShadow()
        }
        .padding(AppTheme.Spacing.lg)
    }

    private var emptyState: some View {
        EmptyStateView(
            symbol: "globe.desk",
            title: "Start building your world",
            message: "Save places you dream of visiting and memories you never want to forget.",
            actionTitle: "Add your first place",
            action: { model.isAddingPlace = true }
        )
        .background(.regularMaterial)
    }
}

#Preview {
    GlobeMapView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
}

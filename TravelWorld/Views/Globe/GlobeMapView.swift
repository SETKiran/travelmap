import SwiftUI
import SwiftData
import MapKit

struct GlobeMapView: View {
    @Environment(\.modelContext) private var context
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

    private var mapLayer: some View {
        Map(position: $model.cameraPosition) {
            ForEach(locations) { location in
                Annotation("", coordinate: location.coordinate) {
                    LocationThumbnailMarker(
                        location: location,
                        isSelected: model.selectedLocation?.uuid == location.uuid
                    )
                    .onTapGesture { model.select(location) }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(model.greeting())
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            Text("Your World")
                .font(.largeTitle.weight(.bold))
            if !locations.isEmpty {
                Text(model.statLine(for: stats))
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                .fill(.regularMaterial)
                .appShadow()
        )
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.sm)
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

import SwiftUI
import SwiftData

struct PlacesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Location.savedDate, order: .reverse) private var locations: [Location]
    @State private var model = PlacesViewModel()
    @State private var editing: Location?

    private var filtered: [Location] { model.filter(locations) }

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if locations.isEmpty {
                    EmptyStateView(
                        symbol: "square.grid.2x2",
                        title: "No places yet",
                        message: "The places you save will collect here, beautifully organized."
                    )
                } else {
                    grid
                }
            }
            .navigationTitle("Places")
            .searchable(text: $model.searchText, prompt: "Search places")
            .safeAreaInset(edge: .top, spacing: 0) { controls }
            .navigationDestination(for: Location.self) { LocationDetailView(location: $0) }
            .sheet(item: $editing) { EditLocationView(location: $0) }
        }
    }

    private var controls: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Picker("Scope", selection: $model.scope) {
                ForEach(PlacesViewModel.Scope.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, AppTheme.Spacing.md)

            let tags = model.availableTags(locations)
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(title: "All", isOn: model.selectedTag == nil) { model.selectedTag = nil }
                        ForEach(tags) { tag in
                            filterChip(title: tag.label, symbol: tag.symbol, isOn: model.selectedTag == tag) {
                                model.selectedTag = model.selectedTag == tag ? nil : tag
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                }
            }
        }
        .padding(.top, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.sm)
        .background(.bar)
    }

    private var grid: some View {
        ScrollView {
            if filtered.isEmpty {
                ContentUnavailableView("No matches", systemImage: "magnifyingglass",
                                       description: Text("Try a different filter or search."))
                    .padding(.top, AppTheme.Spacing.xxl)
            } else {
                LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                    ForEach(filtered) { location in
                        NavigationLink(value: location) {
                            PlaceCard(location: location)
                        }
                        .buttonStyle(.plain)
                        .contextMenu { menu(for: location) }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.xl)
            }
        }
    }

    @ViewBuilder
    private func menu(for location: Location) -> some View {
        if location.status == .wantToVisit {
            Button { markVisited(location) } label: {
                Label("Mark as visited", systemImage: "checkmark.seal.fill")
            }
        }
        Button { editing = location } label: { Label("Edit", systemImage: "pencil") }
        Button(role: .destructive) { delete(location) } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func filterChip(title: String, symbol: String? = nil, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { Haptics.selection(); action() }) {
            HStack(spacing: 4) {
                if let symbol { Image(systemName: symbol).font(.caption2) }
                Text(title).font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(Capsule().fill(isOn ? AppTheme.Colors.accent : AppTheme.Colors.groupedBackground))
            .foregroundStyle(isOn ? .white : AppTheme.Colors.primaryText)
        }
        .buttonStyle(.plain)
    }

    private func markVisited(_ location: Location) {
        withAnimation { location.markVisited() }
        try? context.save()
        Haptics.success()
    }

    private func delete(_ location: Location) {
        location.memoryImageNames.forEach(MemoryImageStore.delete)
        withAnimation { context.delete(location) }
        try? context.save()
        Haptics.light()
    }
}

#Preview {
    PlacesView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
}

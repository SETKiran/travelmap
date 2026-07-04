import SwiftUI
import SwiftData

struct PlacesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Location.savedDate, order: .reverse) private var locations: [Location]
    @State private var model = PlacesViewModel()
    @State private var editing: Location?

    private var filtered: [Location] { model.filter(locations) }

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
                    list
                }
            }
            .navigationTitle("Places")
            .searchable(text: $model.searchText, prompt: "Search places")
            .safeAreaInset(edge: .top, spacing: 0) { controls }
            .sheet(item: $editing) { location in
                EditLocationView(location: location)
            }
        }
    }

    private var controls: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Picker("Scope", selection: $model.scope) {
                ForEach(PlacesViewModel.Scope.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            let tags = model.availableTags(locations)
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(title: "All", isOn: model.selectedTag == nil) {
                            model.selectedTag = nil
                        }
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
        .padding(.horizontal, model.availableTags(locations).isEmpty ? AppTheme.Spacing.md : 0)
        .padding(.top, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.sm)
        .background(.bar)
    }

    private var list: some View {
        List {
            ForEach(filtered) { location in
                NavigationLink {
                    LocationDetailView(location: location)
                } label: {
                    PlaceRow(location: location)
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) { delete(location) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button { editing = location } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(AppTheme.Colors.accent)
                }
                .swipeActions(edge: .leading) {
                    if location.status == .wantToVisit {
                        Button { markVisited(location) } label: {
                            Label("Visited", systemImage: "checkmark.seal.fill")
                        }
                        .tint(AppTheme.Colors.visited)
                    }
                }
            }
        }
        .listStyle(.plain)
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
        context.delete(location)
        try? context.save()
        Haptics.light()
    }
}

#Preview {
    PlacesView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
}

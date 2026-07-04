import SwiftUI
import SwiftData

/// The fast, delightful "add a place" entry point.
struct AddLocationView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var model: AddLocationViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let model {
                    content(model)
                } else {
                    Color.clear
                }
            }
            .navigationTitle("Add a Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .environment(\.dismissAddFlow) { dismiss() }
        .onAppear {
            if model == nil { model = AddLocationViewModel(search: appState.searchService) }
        }
    }

    @ViewBuilder
    private func content(_ model: AddLocationViewModel) -> some View {
        @Bindable var model = model
        List {
            Section {
                importRow(title: "Paste a TikTok / Instagram link",
                          subtitle: "We'll detect the place for you",
                          symbol: "link", destination: .social)
                importRow(title: "Add from a photo",
                          subtitle: "Use a photo's location · coming soon",
                          symbol: "photo.on.rectangle", destination: .photo)
                importRow(title: "Enter manually",
                          subtitle: "Add a place by hand",
                          symbol: "square.and.pencil", destination: .manual)
            }

            Section("Search") {
                if model.isSearching {
                    HStack { ProgressView(); Text("Searching…").foregroundStyle(.secondary) }
                }
                ForEach(model.results) { result in
                    NavigationLink {
                        AddLocationConfirmView(draft: LocationDraft(from: result))
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.name).font(.headline)
                            Text([result.region, result.country].compactMap { $0 }.joined(separator: ", "))
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
                if model.results.isEmpty && !model.isSearching && model.query.count >= 2 {
                    Text("No matches yet.").foregroundStyle(.secondary)
                }
            }
        }
        .searchable(text: $model.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a place")
        .onChange(of: model.query) { model.onQueryChange() }
        .navigationDestination(for: AddRoute.self) { route in
            switch route {
            case .social: SocialLinkImportView()
            case .manual: AddLocationConfirmView(draft: LocationDraft())
            case .photo: PhotoImportView()
            }
        }
    }

    private func importRow(title: String, subtitle: String, symbol: String, destination: AddRoute) -> some View {
        NavigationLink(value: destination) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.body.weight(.medium))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: symbol).foregroundStyle(AppTheme.Colors.accent)
            }
        }
    }
}

enum AddRoute: Hashable { case social, manual, photo }

#Preview {
    AddLocationView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
}

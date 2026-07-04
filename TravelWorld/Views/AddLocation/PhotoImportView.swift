import SwiftUI

/// Privacy-first photo import. Surfaces visited-place suggestions from photo location
/// metadata (mocked) that the user must explicitly confirm. Photos are never uploaded.
struct PhotoImportView: View {
    @Environment(AppState.self) private var appState
    @State private var suggestions: [PhotoPlaceSuggestion] = []
    @State private var isLoading = false

    var body: some View {
        Form {
            Section {
                Label {
                    Text("Nothing is imported automatically. You confirm every place. Photos stay on your device.")
                        .font(.footnote)
                } icon: {
                    Image(systemName: "lock.shield").foregroundStyle(AppTheme.Colors.accent)
                }
            }

            if isLoading {
                Section { HStack { ProgressView(); Text("Looking through photo locations…") } }
            }

            if !suggestions.isEmpty {
                Section("Suggested from your photos") {
                    ForEach(suggestions) { suggestion in
                        NavigationLink {
                            AddLocationConfirmView(draft: draft(for: suggestion))
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(suggestion.name).font(.headline)
                                Text(suggestion.country).font(.subheadline).foregroundStyle(.secondary)
                                Text(suggestion.takenOn, format: .dateTime.month().year())
                                    .font(.caption).foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("From Photos")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            isLoading = true
            suggestions = (try? await appState.photoImport.suggestions()) ?? []
            isLoading = false
        }
    }

    private func draft(for suggestion: PhotoPlaceSuggestion) -> LocationDraft {
        var draft = LocationDraft()
        draft.name = suggestion.name
        draft.country = suggestion.country
        draft.latitude = suggestion.latitude
        draft.longitude = suggestion.longitude
        draft.imageURL = suggestion.thumbnailURL
        draft.status = .visited
        draft.source = .applePhotos
        return draft
    }
}

#Preview {
    NavigationStack { PhotoImportView() }
        .environment(AppState())
        .modelContainer(PreviewData.container)
}

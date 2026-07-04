import SwiftUI
import SwiftData

/// The clean confirmation step before a place joins your world. Ends with a
/// satisfying save animation, then dismisses the whole add flow back to the map.
struct AddLocationConfirmView: View {
    @State var draft: LocationDraft
    @Environment(\.modelContext) private var context
    @Environment(\.dismissAddFlow) private var dismissAddFlow

    @State private var didSave = false

    var body: some View {
        ZStack {
            form
            if didSave { saveOverlay }
        }
        .navigationTitle("Confirm")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var form: some View {
        Form {
            Section {
                PlaceImage(reference: draft.imageURL, seed: draft.name.isEmpty ? "new" : draft.name)
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section("Place") {
                TextField("Name", text: $draft.name)
                TextField("Region", text: $draft.region)
                TextField("Country", text: $draft.country)
            }

            Section("Status") {
                Picker("Status", selection: $draft.status) {
                    ForEach(LocationStatus.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
            }

            Section("Tags") {
                TagSelectionGrid(selected: $draft.tags)
            }

            Section("Note") {
                TextField("Optional — why does this place call to you?", text: $draft.notes, axis: .vertical)
                    .lineLimit(2...5)
            }

            Section {
                Button {
                    save()
                } label: {
                    Text("Save to your world")
                }
                .buttonStyle(PrimaryButtonStyle())
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .disabled(!draft.isValid)
            }
        }
    }

    private var saveOverlay: some View {
        ZStack {
            Rectangle().fill(.regularMaterial).ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppTheme.Colors.accent)
                    .transition(.scale.combined(with: .opacity))
                Text("Added to your world")
                    .font(.title3.weight(.semibold))
            }
        }
        .transition(.opacity)
    }

    private func save() {
        let location = draft.makeLocation()
        context.insert(location)
        try? context.save()
        Haptics.success()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { didSave = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { dismissAddFlow() }
    }
}

#Preview {
    NavigationStack {
        AddLocationConfirmView(draft: LocationDraft(from: SampleData.makeLocations()[0].asSearchResult))
    }
    .modelContainer(PreviewData.container)
}

private extension Location {
    var asSearchResult: PlaceSearchResult {
        PlaceSearchResult(name: name, country: country, region: region,
                          latitude: latitude, longitude: longitude)
    }
}

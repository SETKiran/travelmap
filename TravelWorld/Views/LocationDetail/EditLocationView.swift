import SwiftUI
import SwiftData

struct EditLocationView: View {
    @Bindable var location: Location
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Place") {
                    TextField("Name", text: $location.name)
                    TextField("Region", text: Binding($location.region, replacingNilWith: ""))
                    TextField("Country", text: $location.country)
                }

                Section("Status") {
                    Picker("Status", selection: $location.status) {
                        ForEach(LocationStatus.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notes") {
                    TextField("A memory, a tip, a feeling…", text: Binding($location.notes, replacingNilWith: ""), axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Tags") {
                    TagSelectionGrid(selected: Binding(
                        get: { Set(location.tags) },
                        set: { location.tags = Array($0) }
                    ))
                }

                if location.status == .visited {
                    Section("Your rating") {
                        RatingPicker(rating: Binding($location.personalRating, replacingNilWith: 0))
                    }
                }
            }
            .navigationTitle("Edit Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        try? context.save()
                        Haptics.light()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TagSelectionGrid: View {
    @Binding var selected: Set<LocationTag>
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(LocationTag.allCases) { tag in
                let isOn = selected.contains(tag)
                Button {
                    if isOn { selected.remove(tag) } else { selected.insert(tag) }
                    Haptics.selection()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: tag.symbol).font(.caption)
                        Text(tag.label).font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(isOn ? AppTheme.Colors.accent.opacity(0.18) : AppTheme.Colors.groupedBackground)
                    )
                    .foregroundStyle(isOn ? AppTheme.Colors.accent : AppTheme.Colors.primaryText)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RatingPicker: View {
    @Binding var rating: Int

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(.yellow)
                    .onTapGesture {
                        rating = (rating == i) ? 0 : i
                        Haptics.selection()
                    }
            }
        }
    }
}

// Convenience for binding optionals in Forms.
extension Binding {
    init(_ source: Binding<Value?>, replacingNilWith nilValue: Value) {
        self.init(
            get: { source.wrappedValue ?? nilValue },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}

#Preview {
    EditLocationView(location: PreviewData.sampleLocation)
        .modelContainer(PreviewData.container)
}

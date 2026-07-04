import SwiftUI
import SwiftData
import PhotosUI

/// A mini memory page for a single place.
struct LocationDetailView: View {
    @Bindable var location: Location
    @Environment(\.modelContext) private var context

    @State private var isEditing = false
    @State private var photoItems: [PhotosPickerItem] = []

    private let columns = [GridItem(.adaptive(minimum: 104), spacing: 8)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                hero
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    titleBlock
                    if location.status == .wantToVisit { markVisitedButton }
                    notesSection
                    timelineSection
                    memoriesSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
        .ignoresSafeArea(edges: .top)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { isEditing = true }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareText) { Image(systemName: "square.and.arrow.up") }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditLocationView(location: location)
        }
        .onChange(of: photoItems) { _, items in
            Task { await importMemories(items) }
        }
    }

    // MARK: Sections

    private var hero: some View {
        PlaceImage(reference: location.imageURL, seed: location.name)
            .frame(height: 320)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(alignment: .bottomLeading) {
                LinearGradient(colors: [.clear, .black.opacity(0.55)],
                               startPoint: .center, endPoint: .bottom)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(location.name)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)
                    Text([location.region, location.country].compactMap { $0 }.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(AppTheme.Spacing.md)
            }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                StatusBadge(status: location.status)
                Spacer()
                if let rating = location.personalRating {
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { i in
                            Image(systemName: i < rating ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
            if !location.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack { ForEach(location.tags) { TagChip(tag: $0) } }
                }
            }
        }
    }

    private var markVisitedButton: some View {
        Button {
            withAnimation { location.markVisited() }
            try? context.save()
            Haptics.success()
        } label: {
            Label("Mark as visited", systemImage: "checkmark.seal.fill")
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    @ViewBuilder private var notesSection: some View {
        if let notes = location.notes, !notes.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                sectionTitle("Notes")
                Text(notes).font(.body)
            }
        }
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Timeline")
            timelineRow(symbol: "bookmark.fill", label: "Saved", date: location.savedDate)
            if let visited = location.visitedDate {
                timelineRow(symbol: "checkmark.seal.fill", label: "Visited", date: visited)
            }
        }
    }

    private var memoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                sectionTitle("Memories")
                Spacer()
                PhotosPicker(selection: $photoItems, maxSelectionCount: 5, matching: .images) {
                    Label("Add", systemImage: "plus")
                        .font(.subheadline.weight(.medium))
                }
            }
            if location.memoryImageNames.isEmpty {
                Text("Add photos to remember this place.")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(location.memoryImageNames, id: \.self) { name in
                        MemoryImage(name: name)
                            .frame(height: 104)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous))
                    }
                }
            }
        }
    }

    // MARK: Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text).font(.headline)
    }

    private func timelineRow(symbol: String, label: String, date: Date) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol).foregroundStyle(AppTheme.Colors.accent).frame(width: 24)
            Text(label).font(.subheadline.weight(.medium))
            Spacer()
            Text(date, format: .dateTime.month().day().year())
                .font(.subheadline).foregroundStyle(AppTheme.Colors.secondaryText)
        }
    }

    private var shareText: String {
        location.status == .visited
            ? "I visited \(location.name), \(location.country) — one for the memory books."
            : "\(location.name), \(location.country) is on my travel bucket list."
    }

    private func importMemories(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let name = MemoryImageStore.save(data) {
                location.memoryImageNames.append(name)
            }
        }
        try? context.save()
        photoItems = []
        Haptics.light()
    }
}

#Preview {
    NavigationStack {
        LocationDetailView(location: PreviewData.sampleLocation)
    }
    .modelContainer(PreviewData.container)
}

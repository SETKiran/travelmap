import SwiftUI
import SwiftData

/// The card that rises from the map when a marker is tapped.
struct LocationDetailSheet: View {
    @Bindable var location: Location
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    hero
                    header
                    if let notes = location.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.callout)
                            .foregroundStyle(AppTheme.Colors.primaryText)
                    }
                    timeline
                    actions
                }
                .padding(AppTheme.Spacing.md)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        LocationDetailView(location: location)
                    } label: {
                        Text("Details")
                    }
                }
            }
        }
    }

    private var hero: some View {
        PlaceImage(reference: location.imageURL, seed: location.name)
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(location.name).font(.title.weight(.bold))
            Text([location.region, location.country].compactMap { $0 }.joined(separator: ", "))
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            HStack {
                StatusBadge(status: location.status)
                if !location.tags.isEmpty {
                    ForEach(location.tags.prefix(2)) { TagChip(tag: $0) }
                }
            }
            .padding(.top, 4)
        }
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 8) {
            timelineRow(symbol: "bookmark.fill", label: "Saved", date: location.savedDate)
            if let visited = location.visitedDate {
                timelineRow(symbol: "checkmark.seal.fill", label: "Visited", date: visited)
            }
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous)
                .fill(AppTheme.Colors.groupedBackground)
        )
    }

    private func timelineRow(symbol: String, label: String, date: Date) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol).foregroundStyle(AppTheme.Colors.accent)
            Text(label).font(.subheadline.weight(.medium))
            Spacer()
            Text(date, format: .dateTime.month().day().year())
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.secondaryText)
        }
    }

    @ViewBuilder private var actions: some View {
        if location.status == .wantToVisit {
            Button {
                markVisited()
            } label: {
                Label("Mark as visited", systemImage: "checkmark.seal.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    private func markVisited() {
        withAnimation {
            location.markVisited()
        }
        try? context.save()
        Haptics.success()
    }
}

#Preview {
    LocationDetailSheet(location: PreviewData.sampleLocation)
        .modelContainer(PreviewData.container)
}

import SwiftUI

/// The final, shareable summary card. Designed to render cleanly to an image.
struct RecapShareCard: View {
    let year: Int
    let stats: UserStats
    var markers: [GlobeMarker] = []

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "globe.europe.africa.fill")
                Text("Wander").font(.headline.weight(.bold))
                Spacer()
                Text(String(year)).font(.headline).foregroundStyle(.white.opacity(0.8))
            }
            .foregroundStyle(.white)

            Text("My Year\nin Places")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            WorldGlobeView(markers: markers, lineColor: .white.opacity(0.18))
                .frame(height: 150)
                .frame(maxWidth: .infinity)

            HStack(spacing: AppTheme.Spacing.md) {
                stat(stats.countriesVisited, "countries")
                stat(stats.placesVisited, "visited")
                stat(stats.placesSaved, "saved")
            }

            if !stats.topTags.isEmpty {
                Text(stats.topTags.map(\.label).joined(separator: " · "))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(AppTheme.Spacing.xl)
        .frame(width: 340, height: 480, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [AppTheme.Colors.wantToVisit, AppTheme.Colors.visited],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
    }

    private func stat(_ value: Int, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(value)")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    RecapShareCard(
        year: 2026,
        stats: UserStats(locations: SampleData.makeLocations()),
        markers: SampleData.makeLocations().map {
            GlobeMarker(latitude: $0.latitude, longitude: $0.longitude, isVisited: $0.status == .visited)
        }
    )
}

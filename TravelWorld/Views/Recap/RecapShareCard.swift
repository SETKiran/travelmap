import SwiftUI

/// The final, shareable summary card. Designed to render cleanly to an image.
struct RecapShareCard: View {
    let year: Int
    let stats: UserStats

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            HStack {
                Image(systemName: "globe.europe.africa.fill")
                Text("Wander").font(.headline.weight(.bold))
                Spacer()
                Text(String(year)).font(.headline).foregroundStyle(.white.opacity(0.8))
            }
            .foregroundStyle(.white)

            Text("My Year\nin Places")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            VStack(spacing: AppTheme.Spacing.md) {
                statRow("Countries visited", stats.countriesVisited)
                statRow("Places visited", stats.placesVisited)
                statRow("Dreams saved", stats.placesSaved)
                statRow("Continents", stats.continentsVisited)
            }

            if !stats.topTags.isEmpty {
                Text(stats.topTags.map(\.label).joined(separator: " · "))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(AppTheme.Spacing.xl)
        .frame(width: 340, height: 460, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [AppTheme.Colors.wantToVisit, AppTheme.Colors.visited],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
    }

    private func statRow(_ label: String, _ value: Int) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(value)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.callout)
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
        }
    }
}

#Preview {
    RecapShareCard(year: 2026, stats: UserStats(locations: SampleData.makeLocations()))
}

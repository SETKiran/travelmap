import SwiftUI

/// A modern photo card: full-bleed image, soft gradient scrim, name + country + flag,
/// and a small status pip. Used in the Places grid.
struct PlaceCard: View {
    let location: Location

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            PlaceImage(reference: location.imageURL, seed: location.name)
                .aspectRatio(3.0/4.0, contentMode: .fill)

            LinearGradient(
                colors: [.clear, .black.opacity(0.15), .black.opacity(0.75)],
                startPoint: .center, endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text(CountryFlag.emoji(for: location.country)).font(.caption2)
                    Text(location.country)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                }
            }
            .padding(AppTheme.Spacing.sm + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .topTrailing) { statusPip }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .appShadow()
    }

    private var statusPip: some View {
        Image(systemName: location.status == .visited ? "checkmark" : "sparkles")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .padding(6)
            .background(.ultraThinMaterial, in: Circle())
            .overlay(Circle().stroke(location.status.tint, lineWidth: 2))
            .padding(AppTheme.Spacing.sm)
    }
}

#Preview {
    HStack {
        PlaceCard(location: SampleData.makeLocations()[0]).frame(width: 170)
        PlaceCard(location: SampleData.makeLocations()[1]).frame(width: 170)
    }
    .padding()
}

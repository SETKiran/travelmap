import SwiftUI

struct PlaceRow: View {
    let location: Location

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            PlaceImage(reference: location.imageURL, seed: location.name)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(location.name)
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                Text(location.country)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                StatusBadge(status: location.status, compact: false)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        PlaceRow(location: SampleData.makeLocations()[0])
        PlaceRow(location: SampleData.makeLocations()[1])
    }
}

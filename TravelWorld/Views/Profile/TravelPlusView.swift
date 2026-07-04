import SwiftUI

/// A calm preview of future premium features. No payments — just a taste of what's coming.
struct TravelPlusView: View {
    private let features: [(String, String, String)] = [
        ("infinity", "Unlimited places", "Save as many dreams and memories as you like."),
        ("wand.and.stars", "AI link detection", "Auto-detect places from any social link."),
        ("figure.walk", "Polarsteps sync", "Keep visited places in sync with your trips."),
        ("icloud", "iCloud across devices", "Your world on every device."),
        ("square.and.arrow.up", "Recap export", "Save and share your yearly recap in high resolution."),
        ("map", "Custom map themes", "Make your world truly yours.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(AppTheme.Colors.accent)
                    Text("Travel Plus").font(.largeTitle.weight(.bold))
                    Text("Beautiful extras, when you're ready.")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, AppTheme.Spacing.lg)

                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(features, id: \.0) { feature in
                        AppCard {
                            HStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: feature.0)
                                    .font(.title2)
                                    .foregroundStyle(AppTheme.Colors.accent)
                                    .frame(width: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.1).font(.headline)
                                    Text(feature.2).font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)

                Text("Coming soon")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, AppTheme.Spacing.xl)
            }
        }
        .navigationTitle("Travel Plus")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { TravelPlusView() }
}

import SwiftUI

/// A single full-screen recap story card: blurred image or gradient background,
/// large emotional typography, minimal supporting text.
struct RecapStoryCard: View {
    let card: RecapCard

    var body: some View {
        ZStack {
            background
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Spacer()
                if let symbol = card.symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(.white)
                }
                Text(card.headline)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle = card.subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppTheme.Spacing.xl)
        }
    }

    @ViewBuilder private var background: some View {
        ZStack {
            if let url = card.backgroundImageURL {
                PlaceImage(reference: url, seed: card.gradientSeed)
                    .overlay(.black.opacity(0.4))
            } else {
                GradientPlaceholder(seed: card.gradientSeed)
                    .overlay(.black.opacity(0.15))
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    RecapStoryCard(card: RecapCard(
        headline: "You visited\n12 places.",
        subtitle: "Memories made.",
        symbol: "checkmark.seal.fill",
        backgroundImageURL: nil,
        gradientSeed: "preview"
    ))
}

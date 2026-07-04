import SwiftUI

/// A single full-screen recap story card. Renders differently per `kind` — animated
/// numbers, photo strips, a globe, or a statement over a blurred image.
struct RecapStoryCard: View {
    let card: RecapCard

    @State private var appeared = false
    @State private var counter = 0

    var body: some View {
        ZStack {
            background
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.horizontal, AppTheme.Spacing.xl)
                // Clear the player's progress bars + close button at the top, and the
                // share hint at the bottom, so no slide's content collides with them.
                .padding(.top, 72)
                .padding(.bottom, AppTheme.Spacing.xl)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            if let n = card.bigNumber {
                withAnimation(.snappy(duration: 0.9)) { counter = n }
            }
        }
    }

    // MARK: Content per kind

    @ViewBuilder private var content: some View {
        switch card.kind {
        case .number:       numberContent
        case .photos:       photosContent
        case .globe:        globeContent
        case .personality:  personalityContent
        default:            statementContent
        }
    }

    private var statementContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Spacer()
            symbolView
            Text(card.headline)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle = card.subtitle {
                Text(subtitle).font(.title3).foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var numberContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Spacer()
            symbolView
            Text("\(counter)")
                .font(.system(size: 104, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .contentTransition(.numericText(value: Double(counter)))
            Text(card.headline)
                .font(.title.weight(.semibold))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle = card.subtitle {
                Text(subtitle).font(.body).foregroundStyle(.white.opacity(0.8))
            }
            if !card.imageURLs.isEmpty { photoStrip.padding(.top, AppTheme.Spacing.sm) }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var photosContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Spacer()
            Text(card.headline)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
            let cols = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
            LazyVGrid(columns: cols, spacing: 8) {
                ForEach(Array(card.imageURLs.prefix(6).enumerated()), id: \.offset) { _, url in
                    PlaceImage(reference: url, seed: url)
                        .frame(height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous))
                }
            }
            Spacer()
        }
    }

    private var globeContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Spacer(minLength: 0)
            WorldGlobeView(markers: card.markers, lineColor: .white.opacity(0.18))
                .frame(maxWidth: .infinity)
                .frame(height: 280)
            Text(card.headline)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle = card.subtitle {
                Text(subtitle).font(.title3).foregroundStyle(.white.opacity(0.85))
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var personalityContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Spacer()
            symbolView
            if let subtitle = card.subtitle {
                Text(subtitle.uppercased())
                    .font(.caption.weight(.bold)).tracking(2)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Text(card.headline)
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var photoStrip: some View {
        HStack(spacing: -18) {
            ForEach(Array(card.imageURLs.prefix(4).enumerated()), id: \.offset) { _, url in
                PlaceImage(reference: url, seed: url)
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 2))
            }
        }
    }

    @ViewBuilder private var symbolView: some View {
        if let symbol = card.symbol {
            Image(systemName: symbol)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.white)
        }
    }

    // MARK: Background

    @ViewBuilder private var background: some View {
        ZStack {
            if let url = card.backgroundImageURL {
                PlaceImage(reference: url, seed: card.gradientSeed)
                    .overlay(.black.opacity(0.45))
            } else {
                GradientPlaceholder(seed: card.gradientSeed)
                    .overlay(.black.opacity(0.2))
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    RecapStoryCard(card: RecapCard(
        kind: .number, headline: "places visited", subtitle: "Memories made.",
        symbol: "checkmark.seal.fill", gradientSeed: "preview", bigNumber: 12,
        imageURLs: SampleData.makeLocations().compactMap(\.imageURL)
    ))
}

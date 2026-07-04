import SwiftUI
import SwiftData

/// The Passport tab: an always-on summary of the traveler's world — stats and country
/// "stamps" — plus a button to play the Spotify-Wrapped-style recap story.
struct PassportView: View {
    @Environment(AppState.self) private var appState
    @Query private var locations: [Location]
    @State private var model = RecapViewModel()

    private var year: Int { Calendar.current.component(.year, from: .now) }
    private var stats: UserStats { UserStats(locations: locations) }
    private var visited: [Location] { locations.filter { $0.status == .visited } }

    private var markers: [GlobeMarker] {
        locations.map { GlobeMarker(latitude: $0.latitude, longitude: $0.longitude, isVisited: $0.status == .visited) }
    }

    private var countryStamps: [(country: String, count: Int)] {
        Dictionary(grouping: visited, by: \.country)
            .map { ($0.key, $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    private var memberSince: Int {
        locations.map { Calendar.current.component(.year, from: $0.savedDate) }.min() ?? year
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    passportCard
                    playButton
                    if !countryStamps.isEmpty { stampsSection }
                }
                .padding(AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xl)
            }
            .navigationTitle("Passport")
        }
        .fullScreenCover(isPresented: $model.isPlaying) {
            RecapPlayer(model: model, year: year, stats: stats, markers: markers)
        }
    }

    // MARK: Passport data page

    private var passportCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Label("WANDER", systemImage: "globe.europe.africa.fill")
                    .font(.caption.weight(.bold)).tracking(2)
                Spacer()
                Text("PASSPORT").font(.caption.weight(.bold)).tracking(3)
            }
            .foregroundStyle(.white.opacity(0.9))

            WanderWorldView(markers: markers)
                .frame(height: 150)
                .frame(maxWidth: .infinity)

            HStack(spacing: AppTheme.Spacing.md) {
                stat(stats.countriesVisited, "Countries")
                stat(stats.placesVisited, "Visited")
                stat(stats.continentsVisited, "Continents")
                stat(stats.placesSaved, "Dreams")
            }

            Divider().overlay(.white.opacity(0.25))

            HStack {
                Text("MEMBER SINCE").font(.caption2.weight(.semibold)).tracking(1.5)
                Text(String(memberSince)).font(.caption.weight(.bold))
                Spacer()
                if !stats.topTags.isEmpty {
                    Text(stats.topTags.map(\.label).joined(separator: " · "))
                        .font(.caption)
                }
            }
            .foregroundStyle(.white.opacity(0.85))
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [Color(red: 0.09, green: 0.16, blue: 0.30), AppTheme.Colors.visited],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
        .appShadow()
    }

    private func stat(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Stamps

    private var stampsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Stamps").font(.title3.weight(.semibold))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: AppTheme.Spacing.md)],
                      spacing: AppTheme.Spacing.md) {
                ForEach(Array(countryStamps.enumerated()), id: \.element.country) { index, stamp in
                    stampChip(country: stamp.country, count: stamp.count, index: index)
                }
            }
        }
    }

    private func stampChip(country: String, count: Int, index: Int) -> some View {
        VStack(spacing: 4) {
            Text(CountryFlag.emoji(for: country)).font(.system(size: 30))
            Text(country).font(.caption.weight(.semibold)).lineLimit(1).minimumScaleFactor(0.7)
            Text(count == 1 ? "1 place" : "\(count) places")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .fill(AppTheme.Colors.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        .foregroundStyle(AppTheme.Colors.visited.opacity(0.4))
                )
        )
        .rotationEffect(.degrees(Double((index % 3) - 1) * 2.2))
    }

    private var playButton: some View {
        Button {
            model.build(from: locations, generator: appState.recapGenerator, year: year)
            model.start()
        } label: {
            Label("Play your \(String(year)) in Places", systemImage: "play.circle.fill")
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(locations.isEmpty)
        .opacity(locations.isEmpty ? 0.5 : 1)
    }
}

/// Story-style player: tap right to advance, left to go back, with progress bars.
private struct RecapPlayer: View {
    @Bindable var model: RecapViewModel
    let year: Int
    let stats: UserStats
    let markers: [GlobeMarker]
    @Environment(\.dismiss) private var dismiss

    /// The shareable summary, rendered once when the player appears.
    @State private var shareImage = Image(systemName: "globe")

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            if model.isFinale {
                finale
            } else if let card = model.currentCard {
                RecapStoryCard(card: card)
                    .id(card.id)
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
            }

            tapZones
            topBar
        }
        .task { await renderShareImage() }
    }

    private var topBar: some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(0..<model.stepCount, id: \.self) { i in
                    Capsule()
                        .fill(.white.opacity(i <= model.index ? 0.95 : 0.35))
                        .frame(height: 3)
                }
            }
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Circle().fill(.black.opacity(0.25)))
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.sm)
    }

    private var tapZones: some View {
        HStack(spacing: 0) {
            Rectangle().fill(.clear).contentShape(Rectangle())
                .onTapGesture { model.back() }
            Rectangle().fill(.clear).contentShape(Rectangle())
                .onTapGesture { model.advance() }
        }
        .ignoresSafeArea()
    }

    private var finale: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            RecapShareCard(year: year, stats: stats, markers: markers)
                .appShadow()
            ShareLink(
                item: shareImage,
                preview: SharePreview("My Year in Places", image: shareImage)
            ) {
                Label("Share your year", systemImage: "square.and.arrow.up")
                    .font(.headline).foregroundStyle(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Capsule().fill(.white))
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            Spacer()
        }
    }

    @MainActor
    private func renderShareImage() async {
        let renderer = ImageRenderer(content: RecapShareCard(year: year, stats: stats, markers: markers))
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            shareImage = Image(uiImage: uiImage)
        }
    }
}

#Preview {
    PassportView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
}

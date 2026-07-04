import SwiftUI
import SwiftData

struct RecapView: View {
    @Environment(AppState.self) private var appState
    @Query private var locations: [Location]
    @State private var model = RecapViewModel()

    private var year: Int { Calendar.current.component(.year, from: .now) }
    private var stats: UserStats { UserStats(locations: locations) }

    var body: some View {
        NavigationStack {
            cover
                .navigationTitle("Recap")
                .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $model.isPlaying) {
            RecapPlayer(model: model, year: year, stats: stats)
        }
    }

    private var cover: some View {
        ZStack {
            LinearGradient(colors: [AppTheme.Colors.wantToVisit.opacity(0.9), AppTheme.Colors.visited.opacity(0.9)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.lg) {
                Spacer()
                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(.white)
                Text("Your \(String(year))\nin Places")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                Text("A look back at where you've dreamed and where you've been.")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                Spacer()

                Button {
                    model.build(from: locations, generator: appState.recapGenerator, year: year)
                    model.start()
                } label: {
                    Label("Begin your recap", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(.white))
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .disabled(locations.isEmpty)
                .opacity(locations.isEmpty ? 0.5 : 1)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .padding()
        }
    }
}

/// Story-style player: tap right to advance, left to go back, with progress bars.
private struct RecapPlayer: View {
    @Bindable var model: RecapViewModel
    let year: Int
    let stats: UserStats
    @Environment(\.dismiss) private var dismiss

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
            RecapShareCard(year: year, stats: stats)
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

    @MainActor private var shareImage: Image {
        let renderer = ImageRenderer(content: RecapShareCard(year: year, stats: stats))
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "globe")
    }
}

#Preview {
    RecapView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
}

import WidgetKit
import SwiftUI

/// The hero widget: an orthographic globe with your places glowing on it, plus a
/// compact read on how far your world reaches.
struct WorldMapWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WorldMapWidget", provider: WanderProvider()) { entry in
            WorldMapWidgetView(entry: entry)
                .containerBackground(for: .widget) { WorldWidgetBackground() }
        }
        .configurationDisplayName("Your World")
        .description("A globe of the places you've saved and visited.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct WorldWidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(red: 0.06, green: 0.12, blue: 0.16),
                     Color(red: 0.10, green: 0.20, blue: 0.22)],
            startPoint: .top, endPoint: .bottom
        )
    }
}

struct WorldMapWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: WanderEntry

    private var globe: some View {
        WorldGlobeView(markers: entry.snapshot.globeMarkers)
    }

    var body: some View {
        switch family {
        case .systemSmall:  small
        case .systemLarge:  large
        default:            medium
        }
    }

    private var small: some View {
        ZStack(alignment: .bottomLeading) {
            globe
            VStack(alignment: .leading, spacing: 0) {
                Text("\(entry.snapshot.countriesVisited)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("countries").font(.caption2)
            }
            .foregroundStyle(.white)
            .padding(6)
            .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private var medium: some View {
        HStack(spacing: 16) {
            globe.frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: 12) {
                header
                stat("\(entry.snapshot.countriesVisited)", "countries")
                stat("\(entry.snapshot.placesVisited)", "visited")
                stat("\(entry.snapshot.placesSaved)", "saved")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var large: some View {
        VStack(spacing: 12) {
            HStack {
                header
                Spacer()
                Text("\(entry.snapshot.countriesVisited) countries · \(entry.snapshot.placesVisited) visited")
                    .font(.caption).foregroundStyle(.white.opacity(0.8))
            }
            globe.frame(maxWidth: .infinity, maxHeight: .infinity)
            if let recent = entry.snapshot.visitedPlaces.first {
                Text("Latest memory · \(recent.name), \(recent.country)")
                    .font(.caption).foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 5) {
            Image(systemName: "globe.europe.africa.fill")
            Text("Your World").font(.caption.weight(.semibold))
        }
        .foregroundStyle(.white.opacity(0.9))
    }

    private func stat(_ value: String, _ label: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(value).font(.system(size: 26, weight: .bold, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.footnote).foregroundStyle(.white.opacity(0.8))
        }
    }
}

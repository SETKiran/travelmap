import WidgetKit
import SwiftUI

struct DreamPlaceWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DreamPlaceWidget", provider: WanderProvider()) { entry in
            DreamPlaceWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetGradient(seed: entry.snapshot.dream(offset: entry.rotation)?.name ?? "dream")
                }
        }
        .configurationDisplayName("Dream Place")
        .description("A place you're still dreaming of.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DreamPlaceWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: WanderEntry

    var body: some View {
        let place = entry.snapshot.dream(offset: entry.rotation)
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                    Text("DREAM").font(.caption2.weight(.bold)).tracking(1.5)
                }
                .foregroundStyle(.white.opacity(0.85))
                Spacer()
                if let place {
                    Text("Still dreaming of")
                        .font(.caption).foregroundStyle(.white.opacity(0.8))
                    Text(place.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7).lineLimit(2)
                    HStack(spacing: 5) {
                        Text(CountryFlag.emoji(for: place.country))
                        Text(place.country).font(.caption).foregroundStyle(.white.opacity(0.85))
                    }
                } else {
                    Text("Save your first dream place")
                        .font(.headline).foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            if family != .systemSmall, let place {
                WanderWorldView(markers: [GlobeMarker(latitude: place.latitude, longitude: place.longitude, isVisited: false)])
                    .frame(width: 120, height: 110)
            }
        }
    }
}

import WidgetKit
import SwiftUI

struct MemoryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MemoryWidget", provider: WanderProvider()) { entry in
            MemoryWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetGradient(seed: entry.snapshot.memory(offset: entry.rotation)?.name ?? "memory")
                }
        }
        .configurationDisplayName("Memory")
        .description("Remember a place you've been.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MemoryWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: WanderEntry

    var body: some View {
        let place = entry.snapshot.memory(offset: entry.rotation)
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.seal.fill")
                    Text("MEMORY").font(.caption2.weight(.bold)).tracking(1.5)
                }
                .foregroundStyle(.white.opacity(0.85))
                Spacer()
                if let place {
                    Text("Remember")
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
                    Text("Your memories will appear here")
                        .font(.headline).foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            if family != .systemSmall, let place {
                WanderWorldView(markers: [GlobeMarker(latitude: place.latitude, longitude: place.longitude, isVisited: true)])
                    .frame(width: 120, height: 110)
            }
        }
    }
}

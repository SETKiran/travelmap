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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct DreamPlaceWidgetView: View {
    var entry: WanderEntry

    var body: some View {
        let place = entry.snapshot.dream(offset: entry.rotation)
        VStack(alignment: .leading) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
            if let place {
                Text("Still dreaming of")
                    .font(.caption).foregroundStyle(.white.opacity(0.8))
                Text(place.name)
                    .font(.title2.weight(.bold)).foregroundStyle(.white)
                Text(place.country)
                    .font(.caption).foregroundStyle(.white.opacity(0.85))
            } else {
                Text("Save your first dream place")
                    .font(.headline).foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

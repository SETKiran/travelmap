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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct MemoryWidgetView: View {
    var entry: WanderEntry

    var body: some View {
        let place = entry.snapshot.memory(offset: entry.rotation)
        VStack(alignment: .leading) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
            if let place {
                Text("Remember")
                    .font(.caption).foregroundStyle(.white.opacity(0.8))
                Text("\(place.name)?")
                    .font(.title2.weight(.bold)).foregroundStyle(.white)
                Text(place.country)
                    .font(.caption).foregroundStyle(.white.opacity(0.85))
            } else {
                Text("Your memories will appear here")
                    .font(.headline).foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

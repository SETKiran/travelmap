import WidgetKit
import SwiftUI

struct StatsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "StatsWidget", provider: WanderProvider()) { entry in
            StatsWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetGradient(seed: "wander-stats")
                }
        }
        .configurationDisplayName("Your World")
        .description("Countries visited and places saved at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct StatsWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: WanderEntry

    var body: some View {
        let s = entry.snapshot
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "globe.europe.africa.fill")
                Text("Your World").font(.caption.weight(.semibold))
            }
            .foregroundStyle(.white.opacity(0.9))
            Spacer()
            if family == .systemMedium {
                HStack(spacing: 20) {
                    stat("\(s.countriesVisited)", "countries")
                    stat("\(s.placesVisited)", "visited")
                    stat("\(s.placesSaved)", "saved")
                }
            } else {
                stat("\(s.countriesVisited)", "countries")
                stat("\(s.placesSaved)", "places saved")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value).font(.system(size: 30, weight: .bold, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.caption2).foregroundStyle(.white.opacity(0.85))
        }
    }
}

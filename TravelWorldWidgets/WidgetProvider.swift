import WidgetKit
import SwiftUI

struct WanderEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
    let rotation: Int
}

/// Shared timeline provider. Reads the App Group snapshot and rotates the featured
/// place through the day so the widget stays fresh.
struct WanderProvider: TimelineProvider {
    func placeholder(in context: Context) -> WanderEntry {
        WanderEntry(date: Date(), snapshot: .placeholder, rotation: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (WanderEntry) -> Void) {
        completion(WanderEntry(date: Date(), snapshot: current, rotation: 0))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WanderEntry>) -> Void) {
        let snapshot = current
        let now = Date()
        let cal = Calendar.current
        // Refresh a handful of times over the next several hours, rotating the feature.
        let entries: [WanderEntry] = (0..<6).map { step in
            let date = cal.date(byAdding: .hour, value: step * 3, to: now) ?? now
            return WanderEntry(date: date, snapshot: snapshot, rotation: step)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private var current: WidgetSnapshot {
        WidgetSnapshotStore.read() ?? .placeholder
    }
}

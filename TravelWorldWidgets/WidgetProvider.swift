import WidgetKit
import SwiftUI

struct WanderEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
    let rotation: Int
    /// Longitude offset so the globe appears to spin across timeline refreshes.
    let spin: Double
}

/// Shared timeline provider. Reads the App Group snapshot on every refresh (so newly
/// visited places appear as soon as the app writes them and calls `reloadAllTimelines`),
/// and advances a rotation/spin so the globe feels alive over the day.
struct WanderProvider: TimelineProvider {
    func placeholder(in context: Context) -> WanderEntry {
        WanderEntry(date: Date(), snapshot: .placeholder, rotation: 0, spin: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (WanderEntry) -> Void) {
        // The widget gallery shows sample data; a placed widget shows the real snapshot.
        let snapshot = context.isPreview ? .placeholder : (WidgetSnapshotStore.read() ?? .empty)
        completion(WanderEntry(date: Date(), snapshot: snapshot, rotation: 0, spin: 0))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WanderEntry>) -> Void) {
        let snapshot = current
        let now = Date()
        let cal = Calendar.current
        // Refresh every 15 minutes across the next 6 hours; each step nudges the globe
        // ~9° so it completes a slow rotation over time. WidgetKit will re-request the
        // timeline at the end, and any data change triggers an immediate reload.
        let step = 15
        let count = 24
        let entries: [WanderEntry] = (0..<count).map { i in
            let date = cal.date(byAdding: .minute, value: i * step, to: now) ?? now
            return WanderEntry(date: date, snapshot: snapshot, rotation: i, spin: Double(i) * 9)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    /// The real snapshot the app wrote, or an honest empty state — never fake sample data.
    private var current: WidgetSnapshot {
        WidgetSnapshotStore.read() ?? .empty
    }
}

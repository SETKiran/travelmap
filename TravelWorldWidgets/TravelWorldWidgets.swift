import WidgetKit
import SwiftUI

@main
struct TravelWorldWidgetBundle: WidgetBundle {
    var body: some Widget {
        DreamPlaceWidget()
        MemoryWidget()
        StatsWidget()
    }
}

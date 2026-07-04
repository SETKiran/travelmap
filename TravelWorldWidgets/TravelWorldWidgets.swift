import WidgetKit
import SwiftUI

@main
struct TravelWorldWidgetBundle: WidgetBundle {
    var body: some Widget {
        WorldMapWidget()
        DreamPlaceWidget()
        MemoryWidget()
    }
}

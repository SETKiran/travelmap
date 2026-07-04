import SwiftUI

/// A rounded photo thumbnail used as a map marker — a memory floating on the world.
/// Want-to-visit: soft dashed halo. Visited: solid ring with a small check.
struct LocationThumbnailMarker: View {
    let location: Location
    var size: CGFloat = 52
    var isSelected: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size + 8, height: size + 8)

            PlaceImage(reference: location.imageURL, seed: location.name)
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(
                    Circle().strokeBorder(ringStyle, lineWidth: location.status == .visited ? 3 : 2)
                )
                .overlay(alignment: .bottomTrailing) {
                    if location.status == .visited {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: size * 0.32))
                            .foregroundStyle(.white, AppTheme.Colors.visited)
                            .background(Circle().fill(.white).padding(2))
                            .offset(x: 2, y: 2)
                    }
                }
        }
        .scaleEffect(isSelected ? 1.18 : 1)
        .appShadow(AppTheme.Shadows.marker)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isSelected)
    }

    private var ringStyle: some ShapeStyle {
        location.status == .visited
            ? AnyShapeStyle(AppTheme.Colors.visited)
            : AnyShapeStyle(.white.opacity(0.9))
    }
}

#Preview {
    HStack(spacing: 24) {
        LocationThumbnailMarker(location: SampleData.makeLocations()[0])
        LocationThumbnailMarker(location: SampleData.makeLocations()[1], isSelected: true)
    }
    .padding(40)
    .background(Color.gray)
}

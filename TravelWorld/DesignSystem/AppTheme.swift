import SwiftUI

/// The single source of truth for the app's visual language.
/// Soft neutrals, generous whitespace, subtle depth, elegant type.
enum AppTheme {

    // MARK: Color

    enum Colors {
        /// Calm accent — a muted teal-green that reads as "travel" without being childish.
        static let accent = Color("AccentColor")

        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let groupedBackground = Color(.systemGroupedBackground)

        static let primaryText = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let tertiaryText = Color(.tertiaryLabel)

        static let hairline = Color(.separator)

        /// Want-to-visit places get a soft, dreamy tint.
        static let wantToVisit = Color(red: 0.36, green: 0.55, blue: 0.92)
        /// Visited places get a warm, grounded tint.
        static let visited = Color(red: 0.20, green: 0.62, blue: 0.53)
    }

    // MARK: Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: Radius

    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 18
        static let lg: CGFloat = 28
        static let pill: CGFloat = 999
    }

    // MARK: Shadow

    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    enum Shadows {
        static let soft = ShadowStyle(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
        static let marker = ShadowStyle(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
    }
}

extension View {
    func appShadow(_ style: AppTheme.ShadowStyle = AppTheme.Shadows.soft) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

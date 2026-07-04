import SwiftUI

struct EmptyStateView: View {
    let symbol: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: symbol)
                .font(.system(size: 46, weight: .thin))
                .foregroundStyle(AppTheme.Colors.accent)
                .padding(.bottom, 4)

            Text(title)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(message)
                .font(.callout)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: 260)
                    .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .padding(AppTheme.Spacing.xl)
    }
}

#Preview {
    EmptyStateView(
        symbol: "globe.desk",
        title: "Start building your world",
        message: "Save places you dream of visiting and memories you never want to forget.",
        actionTitle: "Add your first place",
        action: {}
    )
}

import SwiftUI

struct StatusBadge: View {
    let status: LocationStatus
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.symbol)
                .font(.caption2.weight(.semibold))
            if !compact {
                Text(status.title)
                    .font(.caption.weight(.semibold))
            }
        }
        .foregroundStyle(status.tint)
        .padding(.horizontal, compact ? 6 : 10)
        .padding(.vertical, compact ? 4 : 6)
        .background(
            Capsule().fill(status.tint.opacity(0.14))
        )
    }
}

struct TagChip: View {
    let tag: LocationTag

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: tag.symbol).font(.caption2)
            Text(tag.label).font(.caption.weight(.medium))
        }
        .foregroundStyle(AppTheme.Colors.secondaryText)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(AppTheme.Colors.groupedBackground))
    }
}

#Preview {
    VStack(spacing: 16) {
        StatusBadge(status: .wantToVisit)
        StatusBadge(status: .visited)
        TagChip(tag: .nature)
    }
    .padding()
}

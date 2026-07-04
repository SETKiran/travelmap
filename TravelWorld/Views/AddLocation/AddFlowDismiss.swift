import SwiftUI

/// Lets any view inside the add-place flow dismiss the entire sheet, not just pop
/// the current navigation level.
private struct DismissAddFlowKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var dismissAddFlow: () -> Void {
        get { self[DismissAddFlowKey.self] }
        set { self[DismissAddFlowKey.self] = newValue }
    }
}

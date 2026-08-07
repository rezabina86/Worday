import Foundation

/// A value description of the alert the `.alertHost(…)` should show — title, optional message, and one or
/// more buttons. `Equatable` (its button closures are `UserAction`s), so it is snapshot-testable and can
/// be asserted on an `AlertRouterMock`.
struct AlertState: Equatable {
    let title: String
    let message: String?
    let buttons: [Button]

    init(title: String, message: String? = nil, buttons: [Button]) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }
}

extension AlertState {
    struct Button: Equatable {
        let title: String
        let role: Role
        let onTap: UserAction

        init(title: String, role: Role = .standard, onTap: UserAction) {
            self.title = title
            self.role = role
            self.onTap = onTap
        }

        /// The presentation role of a button — mapped to SwiftUI's `ButtonRole` by the host, so the state
        /// stays free of SwiftUI.
        enum Role: Equatable {
            case standard
            case cancel
            case destructive
        }
    }
}

import SwiftUI

/// Adds alert presentation to whatever view it modifies. It observes the `AlertRouterType` and drives
/// `.alert(…)`. Like the other hosts it is dumb: it renders the router's `AlertState` and forwards each
/// button as a `UserAction`, owning no business logic.
///
/// `.alert` has no `item:` overload, so presentation is bound to an `isPresented` bool derived from
/// `presented`. SwiftUI auto-dismisses on any button tap, flipping that bool to `false`, which routes
/// back through `dismiss()` — so the button closures stay pure (just the user's action, not the dismiss).
///
/// Apply it once at the app root via `.alertHost(router:)`, **after** `.modalHost(…)`, so alerts sit
/// above modals and pushed screens.
struct AlertHostModifier: ViewModifier {

    // MARK: - Life Cycle

    init(router: AlertRouterType) {
        self.router = router
    }

    // MARK: - Publics

    func body(content: Content) -> some View {
        // Reading `presented` here registers SwiftUI observation on the router.
        let alert = router.presented
        content.alert(
            alert?.title ?? "",
            isPresented: Binding(
                get: { alert != nil },
                set: { if !$0 { router.dismiss() } }
            ),
            presenting: alert,
            actions: { alert in
                ForEach(Array(alert.buttons.enumerated()), id: \.offset) { _, button in
                    Button(button.title, role: buttonRole(for: button.role)) {
                        button.onTap.action()
                    }
                }
            },
            message: { alert in
                if let message = alert.message {
                    Text(message)
                }
            }
        )
    }

    // MARK: - Privates

    private let router: AlertRouterType

    private func buttonRole(for role: AlertState.Button.Role) -> ButtonRole? {
        switch role {
        case .standard: nil
        case .cancel: .cancel
        case .destructive: .destructive
        }
    }
}

extension View {
    /// Hosts programmatic alerts for this view, driven by the shared `AlertRouterType`.
    func alertHost(router: AlertRouterType) -> some View {
        modifier(AlertHostModifier(router: router))
    }
}

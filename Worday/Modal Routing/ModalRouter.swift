import Observation

/// Coordinates which modal the root `.modalHost(…)` is presenting. A single shared instance is held by
/// the DI container (`.container` scope), so any feature can have it injected and present or dismiss
/// modals programmatically — `present(.info)` / `dismiss()` — without a global singleton and without
/// knowing anything about the presenting view hierarchy.
@MainActor
protocol ModalRouterType: AnyObject {
    var presented: ModalDestination? { get }
    func present(_ destination: ModalDestination)
    func dismiss()
}

@Observable
final class ModalRouter: ModalRouterType {

    // MARK: - Publics

    private(set) var presented: ModalDestination?

    func present(_ destination: ModalDestination) {
        presented = destination
    }

    func dismiss() {
        presented = nil
    }
}

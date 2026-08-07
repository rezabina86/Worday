import Observation

/// Coordinates the single alert the root `.alertHost(…)` is presenting. A shared instance is held by the
/// DI container (`.container` scope), so any feature can have it injected and surface an error or
/// confirmation from anywhere — `present(_:)` / `dismiss()` — without knowing about the view hierarchy
/// and without a global singleton.
///
/// Alerts are strictly one-at-a-time: presenting while one is showing replaces its state.
@MainActor
protocol AlertRouterType: AnyObject {
    var presented: AlertState? { get }
    func present(_ alert: AlertState)
    func dismiss()
}

@Observable
final class AlertRouter: AlertRouterType {

    // MARK: - Publics

    private(set) var presented: AlertState?

    func present(_ alert: AlertState) {
        presented = alert
    }

    func dismiss() {
        presented = nil
    }
}

import Observation

/// Coordinates the app's navigation stack. A single shared instance is held by the DI container
/// (`.container` scope), so any feature can have it injected and push or pop screens programmatically —
/// without a global singleton and without knowing anything about the presenting view hierarchy.
///
/// `push`/`pop`/`popToRoot` are the feature-facing API. `setPath(_:)` exists only so the host's
/// `Binding` can route SwiftUI's own pops (back button, edge swipe) back through the router, keeping it
/// the single source of truth.
@MainActor
protocol NavigationRouterType: AnyObject {
    var path: [NavigationDestination] { get }
    func push(_ destination: NavigationDestination)
    func pop()
    func popToRoot()
    func setPath(_ path: [NavigationDestination])
}

@Observable
final class NavigationRouter: NavigationRouterType {

    // MARK: - Publics

    private(set) var path: [NavigationDestination] = []

    func push(_ destination: NavigationDestination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = []
    }

    func setPath(_ path: [NavigationDestination]) {
        self.path = path
    }
}

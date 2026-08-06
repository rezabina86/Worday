import SwiftUI

/// Hosts the app's navigation stack. It wraps the root content in a `NavigationStack` bound to the
/// shared `NavigationRouterType`'s path, and resolves pushed destinations through the provider. Like the
/// other presentation hosts it is dumb: it owns no business logic and never decides *which* screen to
/// push (that is the router's state and the provider's mapping).
///
/// Applied via `.navigationHost(router:provider:)`.
struct NavigationHostModifier: ViewModifier {

    // MARK: - Life Cycle

    init(router: NavigationRouterType, provider: NavigationDestinationViewProviderType) {
        self.router = router
        self.provider = provider
    }

    // MARK: - Publics

    func body(content: Content) -> some View {
        // Reading `path` here registers SwiftUI observation on the router, so programmatic push/pop
        // calls re-render. The binding's setter routes SwiftUI's own pops (back button, edge swipe)
        // back through the router, keeping it the single source of truth.
        let path = router.path
        return NavigationStack(path: Binding(
            get: { path },
            set: { router.setPath($0) }
        )) {
            content
                .navigationDestination(for: NavigationDestination.self) { destination in
                    provider.view(for: destination)
                }
        }
    }

    // MARK: - Privates

    private let router: NavigationRouterType
    private let provider: NavigationDestinationViewProviderType
}

extension View {
    /// Hosts the app's navigation stack, driven by the shared `NavigationRouterType`.
    func navigationHost(
        router: NavigationRouterType,
        provider: NavigationDestinationViewProviderType
    ) -> some View {
        modifier(NavigationHostModifier(router: router, provider: provider))
    }
}

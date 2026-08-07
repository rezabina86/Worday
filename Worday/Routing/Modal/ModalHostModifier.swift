import SwiftUI

/// Adds modal presentation to whatever view it modifies. It observes the `ModalRouterType` and drives
/// both `.sheet(item:)` and `.fullScreenCover(item:)`, routing the current destination to exactly one of
/// them based on its `presentationStyle`. Like the other hosts it is dumb: it owns no business logic and
/// never decides *which* screen to show — that is the provider's job.
///
/// Apply it once at the app root via `.modalHost(router:provider:)`, outermost so modals cover pushed
/// screens.
struct ModalHostModifier: ViewModifier {

    // MARK: - Life Cycle

    init(router: ModalRouterType, provider: ModalDestinationViewProviderType) {
        self.router = router
        self.provider = provider
    }

    // MARK: - Publics

    func body(content: Content) -> some View {
        // Reading `presented` here registers SwiftUI observation on the router, so programmatic
        // present/dismiss calls re-render. The two modifiers bind to disjoint items (only the
        // destination matching each style is ever non-nil) so they never fight to present.
        let presented = router.presented
        content
            .sheet(item: item(in: presented, where: isSheet)) { destination in
                provider.view(for: destination)
                    .presentationDetents(detents(for: destination))
            }
            .fullScreenCover(item: item(in: presented, where: isFullScreenCover)) { destination in
                provider.view(for: destination)
            }
    }

    // MARK: - Privates

    private let router: ModalRouterType
    private let provider: ModalDestinationViewProviderType

    /// Exposes `presented` only when it matches `predicate`, and routes any system dismiss (swipe /
    /// interactive) back through the router.
    private func item(
        in presented: ModalDestination?,
        where predicate: (ModalDestination) -> Bool
    ) -> Binding<ModalDestination?> {
        let matched = presented.flatMap { predicate($0) ? $0 : nil }
        return Binding(
            get: { matched },
            set: { if $0 == nil { router.dismiss() } }
        )
    }

    private func isSheet(_ destination: ModalDestination) -> Bool {
        if case .sheet = destination.presentationStyle { return true }
        return false
    }

    private func isFullScreenCover(_ destination: ModalDestination) -> Bool {
        destination.presentationStyle == .fullScreenCover
    }

    private func detents(for destination: ModalDestination) -> Set<PresentationDetent> {
        if case let .sheet(detents) = destination.presentationStyle { return detents }
        return [.large]
    }
}

extension View {
    /// Hosts programmatic modal presentation for this view, driven by the shared `ModalRouterType`.
    func modalHost(router: ModalRouterType, provider: ModalDestinationViewProviderType) -> some View {
        modifier(ModalHostModifier(router: router, provider: provider))
    }
}

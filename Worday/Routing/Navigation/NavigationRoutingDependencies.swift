import Foundation

extension ContainerType {
    /// The navigation router (shared `.container` state) and the destination→screen provider.
    func registerNavigationRoutingDependencies() {
        register(in: .container) { _ in NavigationRouter() as NavigationRouterType }

        register { container in
            NavigationDestinationViewProvider(wordListViewStateConverter: container.resolve(),
                                              wordMeaningViewModelFactory: container.resolve())
            as NavigationDestinationViewProviderType
        }
    }
}

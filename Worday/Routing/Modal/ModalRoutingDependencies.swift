import Foundation

extension ContainerType {
    /// The modal router (shared `.container` state) and the destination→screen provider.
    func registerModalRoutingDependencies() {
        register(in: .container) { _ in ModalRouter() as ModalRouterType }

        register { container in
            ModalDestinationViewProvider(infoModalViewStateConverter: container.resolve())
            as ModalDestinationViewProviderType
        }
    }
}

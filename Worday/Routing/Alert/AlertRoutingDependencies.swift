import Foundation

extension ContainerType {
    /// The alert router (shared `.container` state). No provider — `AlertState` is a plain value.
    func registerAlertRoutingDependencies() {
        register(in: .container) { _ in AlertRouter() as AlertRouterType }
    }
}

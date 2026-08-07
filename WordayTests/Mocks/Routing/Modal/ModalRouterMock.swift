@testable import Worday

final class ModalRouterMock: ModalRouterType {

    enum Call: Equatable {
        case present(destination: ModalDestination)
        case dismiss
    }

    private(set) var presented: ModalDestination?

    func present(_ destination: ModalDestination) {
        presented = destination
        calls.append(.present(destination: destination))
    }

    func dismiss() {
        presented = nil
        calls.append(.dismiss)
    }

    private(set) var calls: [Call] = []
}

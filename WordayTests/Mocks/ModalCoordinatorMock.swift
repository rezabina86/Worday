import Foundation
@testable import Worday

final class ModalCoordinatorMock: ModalCoordinatorType {

    enum Call: Equatable {
        case present(destination: ModalCoordinatorDestination?)
    }

    var destination: ModalCoordinatorDestination?

    func present(_ destination: ModalCoordinatorDestination?) {
        self.destination = destination
        calls.append(.present(destination: destination))
    }

    private(set) var calls: [Call] = []
}

import Foundation
import Observation

enum ModalCoordinatorDestination: Identifiable, Equatable {
    case info(InfoModalViewState)

    var id: String {
        switch self {
        case .info:
            "info_modal"
        }
    }
}

protocol ModalCoordinatorType: AnyObject {
    var destination: ModalCoordinatorDestination? { get set }
    func present(_ destination: ModalCoordinatorDestination?)
}

@Observable
final class ModalCoordinator: ModalCoordinatorType {

    // MARK: - Publics

    var destination: ModalCoordinatorDestination?

    func present(_ destination: ModalCoordinatorDestination?) {
        self.destination = destination
    }
}

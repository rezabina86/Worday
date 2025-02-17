import Combine
import Foundation

enum ModalCoordinatorDestination: Identifiable, Equatable {
    case info(InfoModalViewState)
    
    var id: String {
        switch self {
        case .info:
            "info_modal"
        }
    }
}

protocol ModalCoordinatorType {
    func present(_ destination: ModalCoordinatorDestination?)
    var currentDestination: AnyPublisher<ModalCoordinatorDestination?, Never> { get }
}

final class ModalCoordinator: ModalCoordinatorType {
    
    var currentDestination: AnyPublisher<ModalCoordinatorDestination?, Never> {
        currentDestinationSubject.eraseToAnyPublisher()
    }
    
    func present(_ destination: ModalCoordinatorDestination?) {
        currentDestinationSubject.send(destination)
    }
    
    // MARK: - Privates
    private let currentDestinationSubject: CurrentValueSubject<ModalCoordinatorDestination?, Never> = .init(nil)
}

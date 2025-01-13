import Combine
@testable import Worday

final class ModalCoordinatorMock: ModalCoordinatorType {
    
    enum Call: Equatable {
        case present(destination: ModalCoordinatorDestination?)
    }
    
    var currentDestination: AnyPublisher<ModalCoordinatorDestination?, Never> {
        currentDestinationSubject.eraseToAnyPublisher()
    }
    
    func present(_ destination: ModalCoordinatorDestination?) {
        calls.append(.present(destination: destination))
    }
    
    var calls: [Call] = []
    var currentDestinationSubject: CurrentValueSubject<ModalCoordinatorDestination?, Never> = .init(nil)
}

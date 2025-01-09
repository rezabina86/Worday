import Combine
import SwiftUI
import Foundation
@testable import Worday

final class GameViewModelMock: GameViewModelType {
    
    enum Call: Equatable {
        case scenePhaseChanged(scenePhase: ScenePhase)
        case setModalDestination(destination: ModalCoordinatorDestination?)
    }
    
    var viewState: AnyPublisher<GameViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    var currentDestination: AnyPublisher<ModalCoordinatorDestination?, Never> {
        currentDestinationSubject.eraseToAnyPublisher()
    }
    
    func scenePhaseChanged(_ scenePhase: ScenePhase) {
        calls.append(.scenePhaseChanged(scenePhase: scenePhase))
    }
    
    func setModalDestination(_ destination: ModalCoordinatorDestination?) {
        calls.append(.setModalDestination(destination: destination))
    }
    
    var calls: [Call] = []
    let viewStateSubject: CurrentValueSubject<GameViewState, Never> = .init(.empty)
    let currentDestinationSubject: CurrentValueSubject<ModalCoordinatorDestination?, Never> = .init(nil)
}

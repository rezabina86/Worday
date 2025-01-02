import Combine
import Foundation
@testable import Worday

final class OngoingGameViewModelMock: OngoingGameViewModelType {
    
    var viewState: AnyPublisher<GameViewState.OngoingGameViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    let viewStateSubject: CurrentValueSubject<GameViewState.OngoingGameViewState, Never> = .init(.empty)
}


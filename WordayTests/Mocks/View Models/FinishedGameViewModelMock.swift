import Combine
import Foundation
@testable import Worday

final class FinishedGameViewModelMock: FinishedGameViewModelType {
    
    var viewState: AnyPublisher<FinishedGameViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    let viewStateSubject: CurrentValueSubject<FinishedGameViewState, Never> = .init(.empty)
    
}

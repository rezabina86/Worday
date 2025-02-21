import Combine
import Foundation
@testable import Worday

final class WordMeaningViewModelMock: WordMeaningViewModelType {
    
    var viewState: AnyPublisher<WordMeaningViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    var viewStateSubject: CurrentValueSubject<WordMeaningViewState, Never> = .init(.loading)
}

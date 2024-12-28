import Foundation
import Combine

protocol GameViewModelFactoryType {
    func create() -> GameViewModelType
}

struct GameViewModelFactory: GameViewModelFactoryType {
    let fetchWordUseCase: FetchWordUseCaseType
    
    func create() -> GameViewModelType {
        GameViewModel(fetchWordUseCase: fetchWordUseCase)
    }
}

protocol GameViewModelType {
    var viewState: AnyPublisher<GameViewState, Never> { get }
}

final class GameViewModel: GameViewModelType {
    
    init(fetchWordUseCase: FetchWordUseCaseType) {
        self.fetchWordUseCase = fetchWordUseCase
        
        updateViewState()
    }
    
    var viewState: AnyPublisher<GameViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Privates
    private let fetchWordUseCase: FetchWordUseCaseType
    
    private let viewStateSubject: CurrentValueSubject<GameViewState, Never> = .init(.error)
    
    private func updateViewState() {
        let result = fetchWordUseCase.fetch()
        
        switch result {
        case .error:
            viewStateSubject.send(.error)
        case let .word(word):
            viewStateSubject.send(.game(word: word))
        case let .noWordToday(lastPlayedWord):
            viewStateSubject.send(.noWordToday(lastWord: lastPlayedWord))
        }
    }
}

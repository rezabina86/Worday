import Foundation
import Combine

protocol GameViewModelFactoryType {
    func create() -> GameViewModelType
}

struct GameViewModelFactory: GameViewModelFactoryType {
    let fetchWordUseCase: WordProviderUseCaseType
    
    func create() -> GameViewModelType {
        GameViewModel(wordProviderUseCase: fetchWordUseCase)
    }
}

protocol GameViewModelType {
    var viewState: AnyPublisher<GameViewState, Never> { get }
}

final class GameViewModel: GameViewModelType {
    
    init(wordProviderUseCase: WordProviderUseCaseType) {
        self.wordProviderUseCase = wordProviderUseCase
        
        updateViewState()
    }
    
    var viewState: AnyPublisher<GameViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Privates
    private let wordProviderUseCase: WordProviderUseCaseType
    
    private let viewStateSubject: CurrentValueSubject<GameViewState, Never> = .init(.error)
    
    private func updateViewState() {
        let result = wordProviderUseCase.fetch()
        
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

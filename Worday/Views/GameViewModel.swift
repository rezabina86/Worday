import Foundation
import Combine

protocol GameViewModelFactoryType {
    func create() -> GameViewModelType
}

struct GameViewModelFactory: GameViewModelFactoryType {
    let fetchWordUseCase: WordProviderUseCaseType
    let ongoingGameViewModelFactory: OngoingGameViewModelFactoryType
    
    func create() -> GameViewModelType {
        GameViewModel(wordProviderUseCase: fetchWordUseCase,
                      ongoingGameViewModelFactory: ongoingGameViewModelFactory)
    }
}

protocol GameViewModelType {
    var viewState: AnyPublisher<GameViewState, Never> { get }
}

final class GameViewModel: GameViewModelType {
    
    init(wordProviderUseCase: WordProviderUseCaseType,
         ongoingGameViewModelFactory: OngoingGameViewModelFactoryType) {
        self.wordProviderUseCase = wordProviderUseCase
        self.ongoingGameViewModelFactory = ongoingGameViewModelFactory
        
        fetchWord()
    }
    
    var viewState: AnyPublisher<GameViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Privates
    private let wordProviderUseCase: WordProviderUseCaseType
    private let ongoingGameViewModelFactory: OngoingGameViewModelFactoryType
    
    private var ongoingGameViewModel: OngoingGameViewModelType?
    
    private let viewStateSubject: CurrentValueSubject<GameViewState, Never> = .init(.error)
    private var cancellables: Set<AnyCancellable> = []
    
    private func fetchWord() {
        let result = wordProviderUseCase.fetch()
        
        switch result {
        case .error:
            viewStateSubject.send(.error)
        case let .word(word):
            setupOngoingGame(with: word)
        case let .noWordToday(lastPlayedWord):
            viewStateSubject.send(.noWordToday(lastWord: lastPlayedWord))
        }
    }
    
    private func setupOngoingGame(with word: String) {
        ongoingGameViewModel = ongoingGameViewModelFactory.create(with: word)
        
        ongoingGameViewModel?.viewState
            .sink { [viewStateSubject] in
                viewStateSubject.send(.game(viewState: $0))
            }
            .store(in: &cancellables)
    }
}

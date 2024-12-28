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
    }
    
    var viewState: AnyPublisher<GameViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Privates
    private let fetchWordUseCase: FetchWordUseCaseType
    
    private let viewStateSubject: CurrentValueSubject<GameViewState, Never> = .init(.error)
}

import Foundation
import Combine
import SwiftUI

protocol GameViewModelFactoryType {
    func create() -> GameViewModelType
}

struct GameViewModelFactory: GameViewModelFactoryType {
    let fetchWordUseCase: WordProviderUseCaseType
    let ongoingGameViewModelFactory: OngoingGameViewModelFactoryType
    let finishedGameViewModelFactory: FinishedGameViewModelFactoryType
    let scenePhaseObserver: ScenePhaseObserverType
    let appTriggerFactory: AppTriggerFactoryType
    
    func create() -> GameViewModelType {
        GameViewModel(wordProviderUseCase: fetchWordUseCase,
                      ongoingGameViewModelFactory: ongoingGameViewModelFactory,
                      finishedGameViewModelFactory: finishedGameViewModelFactory,
                      scenePhaseObserver: scenePhaseObserver,
                      appTriggerFactory: appTriggerFactory)
    }
}

protocol GameViewModelType {
    var viewState: AnyPublisher<GameViewState, Never> { get }
    func scenePhaseChanged(_ scenePhase: ScenePhase)
}

final class GameViewModel: GameViewModelType {
    
    init(wordProviderUseCase: WordProviderUseCaseType,
         ongoingGameViewModelFactory: OngoingGameViewModelFactoryType,
         finishedGameViewModelFactory: FinishedGameViewModelFactoryType,
         scenePhaseObserver: ScenePhaseObserverType,
         appTriggerFactory: AppTriggerFactoryType) {
        self.wordProviderUseCase = wordProviderUseCase
        self.ongoingGameViewModelFactory = ongoingGameViewModelFactory
        self.finishedGameViewModelFactory = finishedGameViewModelFactory
        self.scenePhaseObserver = scenePhaseObserver
        self.appTriggerFactory = appTriggerFactory
        
        makeTrigger
            .sink { [weak self] _ in
                guard let self else { return }
                self.fetchWord()
            }
            .store(in: &cancellables)
    }
    
    var viewState: AnyPublisher<GameViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    func scenePhaseChanged(_ scenePhase: ScenePhase) {
        scenePhaseObserver.phaseChanged(scenePhase)
    }
    
    // MARK: - Privates
    private let wordProviderUseCase: WordProviderUseCaseType
    private let ongoingGameViewModelFactory: OngoingGameViewModelFactoryType
    private let finishedGameViewModelFactory: FinishedGameViewModelFactoryType
    private let scenePhaseObserver: ScenePhaseObserverType
    private let appTriggerFactory: AppTriggerFactoryType
    
    private var ongoingGameViewModel: OngoingGameViewModelType?
    private var finishedGameViewModel: FinishedGameViewModelType?
    
    private let viewStateSubject: CurrentValueSubject<GameViewState, Never> = .init(.empty)
    private var cancellables: Set<AnyCancellable> = []
    
    private func fetchWord() {
        let result = wordProviderUseCase.fetch()
        
        switch result {
        case .error:
            viewStateSubject.send(.error)
        case let .word(word):
            setupOngoingGame(with: word)
        case let .noWordToday(lastPlayedWord):
            setupFinishedGame(with: lastPlayedWord)
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
    
    private func setupFinishedGame(with word: String) {
        finishedGameViewModel = finishedGameViewModelFactory.create(for: word)
        
        finishedGameViewModel?.viewState
            .sink { [viewStateSubject] in
                viewStateSubject.send(.noWordToday(viewState: $0))
            }
            .store(in: &cancellables)
    }
    
    private var makeTrigger: AnyPublisher<Void, Never> {
        appTriggerFactory.create(of: [
            .appBecameActive,
            .gameFinished
        ])
    }
}

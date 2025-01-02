import Foundation
import Combine
import SwiftUI

protocol GameViewModelFactoryType {
    func create() -> GameViewModelType
}

struct GameViewModelFactory: GameViewModelFactoryType {
    let fetchWordUseCase: WordProviderUseCaseType
    let ongoingGameViewModelFactory: OngoingGameViewModelFactoryType
    let scenePhaseObserver: ScenePhaseObserverType
    let appTriggerFactory: AppTriggerFactoryType
    
    func create() -> GameViewModelType {
        GameViewModel(wordProviderUseCase: fetchWordUseCase,
                      ongoingGameViewModelFactory: ongoingGameViewModelFactory,
                      scenePhaseObserver: scenePhaseObserver,
                      appTriggerFactory: appTriggerFactory)
    }
}

protocol GameViewModelType {
    var viewState: AnyPublisher<GameViewState, Never> { get }
    func onAppear()
    func scenePhaseChanged(_ scenePhase: ScenePhase)
}

final class GameViewModel: GameViewModelType {
    
    init(wordProviderUseCase: WordProviderUseCaseType,
         ongoingGameViewModelFactory: OngoingGameViewModelFactoryType,
         scenePhaseObserver: ScenePhaseObserverType,
         appTriggerFactory: AppTriggerFactoryType) {
        self.wordProviderUseCase = wordProviderUseCase
        self.ongoingGameViewModelFactory = ongoingGameViewModelFactory
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
    
    func onAppear() {
        scenePhaseObserver.appAppeared()
    }
    
    func scenePhaseChanged(_ scenePhase: ScenePhase) {
        scenePhaseObserver.phaseChanged(scenePhase)
    }
    
    // MARK: - Privates
    private let wordProviderUseCase: WordProviderUseCaseType
    private let ongoingGameViewModelFactory: OngoingGameViewModelFactoryType
    private let scenePhaseObserver: ScenePhaseObserverType
    private let appTriggerFactory: AppTriggerFactoryType
    
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
            let viewState = FinishedGameViewState(
                title: "Great job!",
                message: "You’ve solved today’s puzzle. The word was \(lastPlayedWord)",
                subtitle: "Come back tomorrow for another challenge!"
            )
            viewStateSubject.send(.noWordToday(viewState: viewState))
        }
    }
    
    private func setupOngoingGame(with word: String) {
        if ongoingGameViewModel == nil {
            ongoingGameViewModel = ongoingGameViewModelFactory.create(with: word)
        }
        
        ongoingGameViewModel?.viewState
            .sink { [viewStateSubject] in
                viewStateSubject.send(.game(viewState: $0))
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

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
    let modalCoordinator: ModalCoordinatorType
    
    func create() -> GameViewModelType {
        GameViewModel(wordProviderUseCase: fetchWordUseCase,
                      ongoingGameViewModelFactory: ongoingGameViewModelFactory,
                      finishedGameViewModelFactory: finishedGameViewModelFactory,
                      scenePhaseObserver: scenePhaseObserver,
                      appTriggerFactory: appTriggerFactory,
                      modalCoordinator: modalCoordinator)
    }
}

protocol GameViewModelType {
    var viewState: AnyPublisher<GameViewState, Never> { get }
    func scenePhaseChanged(_ scenePhase: ScenePhase)
    func setModalDestination(_ destination: ModalCoordinatorDestination?)
    var currentDestination: AnyPublisher<ModalCoordinatorDestination?, Never> { get }
}

final class GameViewModel: GameViewModelType {
    
    init(wordProviderUseCase: WordProviderUseCaseType,
         ongoingGameViewModelFactory: OngoingGameViewModelFactoryType,
         finishedGameViewModelFactory: FinishedGameViewModelFactoryType,
         scenePhaseObserver: ScenePhaseObserverType,
         appTriggerFactory: AppTriggerFactoryType,
         modalCoordinator: ModalCoordinatorType) {
        self.wordProviderUseCase = wordProviderUseCase
        self.ongoingGameViewModelFactory = ongoingGameViewModelFactory
        self.finishedGameViewModelFactory = finishedGameViewModelFactory
        self.scenePhaseObserver = scenePhaseObserver
        self.appTriggerFactory = appTriggerFactory
        self.modalCoordinator = modalCoordinator
        
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
    
    var currentDestination: AnyPublisher<ModalCoordinatorDestination?, Never> {
        modalCoordinator.currentDestination.eraseToAnyPublisher()
    }
    
    func scenePhaseChanged(_ scenePhase: ScenePhase) {
        scenePhaseObserver.phaseChanged(scenePhase)
    }
    
    func setModalDestination(_ destination: ModalCoordinatorDestination?) {
        modalCoordinator.present(destination)
    }
    
    // MARK: - Privates
    private let wordProviderUseCase: WordProviderUseCaseType
    private let ongoingGameViewModelFactory: OngoingGameViewModelFactoryType
    private let finishedGameViewModelFactory: FinishedGameViewModelFactoryType
    private let scenePhaseObserver: ScenePhaseObserverType
    private let appTriggerFactory: AppTriggerFactoryType
    private let modalCoordinator: ModalCoordinatorType
    
    private var ongoingGameViewModel: OngoingGameViewModelType?
    private var finishedGameViewModel: FinishedGameViewModelType?
    
    private let viewStateSubject: CurrentValueSubject<GameViewState, Never> = .init(.empty)
    private var cancellables: Set<AnyCancellable> = []
    
    private var latestFetchResult: FetchWordModel?
    
    private func fetchWord() {
        let result = wordProviderUseCase.fetch()
        
        guard result != latestFetchResult else { return }
        
        switch result {
        case .error:
            viewStateSubject.send(.error)
        case let .word(word):
            setupOngoingGame(with: word)
        case let .noWordToday(lastPlayedWord):
            setupFinishedGame(with: lastPlayedWord)
        }
        
        latestFetchResult = result
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

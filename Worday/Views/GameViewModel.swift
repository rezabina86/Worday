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
    let navigationRouter: NavigationRouterType
    
    func create() -> GameViewModelType {
        GameViewModel(wordProviderUseCase: fetchWordUseCase,
                      ongoingGameViewModelFactory: ongoingGameViewModelFactory,
                      finishedGameViewModelFactory: finishedGameViewModelFactory,
                      scenePhaseObserver: scenePhaseObserver,
                      appTriggerFactory: appTriggerFactory,
                      modalCoordinator: modalCoordinator,
                      navigationRouter: navigationRouter)
    }
}

protocol GameViewModelType {
    var viewState: AnyPublisher<GameViewState, Never> { get }
    func scenePhaseChanged(_ scenePhase: ScenePhase)
    
    // Modal Coordinator
    var currentDestination: AnyPublisher<ModalCoordinatorDestination?, Never> { get }
    func setModalDestination(_ destination: ModalCoordinatorDestination?)
    
    // Navigation Router
    var currentNavigationPath: AnyPublisher<NavigationPath, Never> { get }
    func setNavigationCurrentPath(_ path: NavigationPath)
}

final class GameViewModel: GameViewModelType {
    
    init(wordProviderUseCase: WordProviderUseCaseType,
         ongoingGameViewModelFactory: OngoingGameViewModelFactoryType,
         finishedGameViewModelFactory: FinishedGameViewModelFactoryType,
         scenePhaseObserver: ScenePhaseObserverType,
         appTriggerFactory: AppTriggerFactoryType,
         modalCoordinator: ModalCoordinatorType,
         navigationRouter: NavigationRouterType) {
        self.wordProviderUseCase = wordProviderUseCase
        self.ongoingGameViewModelFactory = ongoingGameViewModelFactory
        self.finishedGameViewModelFactory = finishedGameViewModelFactory
        self.scenePhaseObserver = scenePhaseObserver
        self.appTriggerFactory = appTriggerFactory
        self.modalCoordinator = modalCoordinator
        self.navigationRouter = navigationRouter
        
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
    
    var currentNavigationPath: AnyPublisher<NavigationPath, Never> {
        navigationRouter.currentPath.eraseToAnyPublisher()
    }
    
    func setNavigationCurrentPath(_ path: NavigationPath) {
        navigationRouter.setCurrentPath(path)
    }
    
    // MARK: - Privates
    private let wordProviderUseCase: WordProviderUseCaseType
    private let ongoingGameViewModelFactory: OngoingGameViewModelFactoryType
    private let finishedGameViewModelFactory: FinishedGameViewModelFactoryType
    private let scenePhaseObserver: ScenePhaseObserverType
    private let appTriggerFactory: AppTriggerFactoryType
    private let modalCoordinator: ModalCoordinatorType
    private let navigationRouter: NavigationRouterType
    
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
            viewStateSubject.send(.game(viewModel: ongoingGameViewModelFactory.create(with: word)))
        case let .noWordToday(lastPlayedWord):
            viewStateSubject.send(.noWordToday(viewModel: finishedGameViewModelFactory.create(for: lastPlayedWord)))
        }
        
        latestFetchResult = result
    }
    
    private var makeTrigger: AnyPublisher<Void, Never> {
        appTriggerFactory.create(of: [
            .appBecameActive,
            .gameFinished
        ])
    }
}

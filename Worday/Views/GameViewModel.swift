import Foundation
import SwiftUI
import Observation

protocol GameViewModelFactoryType {
    func make() -> GameViewModelType
}

struct GameViewModelFactory: GameViewModelFactoryType {
    let fetchWordUseCase: WordProviderUseCaseType
    let ongoingGameViewModelFactory: OngoingGameViewModelFactoryType
    let finishedGameViewModelFactory: FinishedGameViewModelFactoryType
    let finishGameRelay: FinishGameRelayType
    let modalCoordinator: ModalCoordinatorType
    let navigationRouter: NavigationRouterType

    func make() -> GameViewModelType {
        GameViewModel(wordProviderUseCase: fetchWordUseCase,
                      ongoingGameViewModelFactory: ongoingGameViewModelFactory,
                      finishedGameViewModelFactory: finishedGameViewModelFactory,
                      finishGameRelay: finishGameRelay,
                      modalCoordinator: modalCoordinator,
                      navigationRouter: navigationRouter)
    }
}

protocol GameViewModelType: AnyObject {
    var viewState: GameViewState { get }
    var navigationPath: NavigationPath { get set }
    var modalDestination: ModalCoordinatorDestination? { get set }

    /// Re-reads the day's state and rebuilds the view state. Called on appear and when the app
    /// becomes active. Deduped against the last result.
    func refresh()

    /// Awaits game-finished events for the app's lifetime, re-fetching after each.
    func observeGameFinished() async
}

@Observable
final class GameViewModel: GameViewModelType {

    // MARK: - Life Cycle

    init(wordProviderUseCase: WordProviderUseCaseType,
         ongoingGameViewModelFactory: OngoingGameViewModelFactoryType,
         finishedGameViewModelFactory: FinishedGameViewModelFactoryType,
         finishGameRelay: FinishGameRelayType,
         modalCoordinator: ModalCoordinatorType,
         navigationRouter: NavigationRouterType) {
        self.wordProviderUseCase = wordProviderUseCase
        self.ongoingGameViewModelFactory = ongoingGameViewModelFactory
        self.finishedGameViewModelFactory = finishedGameViewModelFactory
        self.finishGameRelay = finishGameRelay
        self.modalCoordinator = modalCoordinator
        self.navigationRouter = navigationRouter
    }

    // MARK: - Publics

    private(set) var viewState: GameViewState = .empty

    var navigationPath: NavigationPath {
        get { navigationRouter.path }
        set { navigationRouter.path = newValue }
    }

    var modalDestination: ModalCoordinatorDestination? {
        get { modalCoordinator.destination }
        set { modalCoordinator.present(newValue) }
    }

    func refresh() {
        let result = wordProviderUseCase.fetch()

        guard result != latestFetchResult else { return }

        switch result {
        case .error:
            viewState = .error
        case let .word(word):
            viewState = .game(viewModel: ongoingGameViewModelFactory.make(with: word))
        case let .noWordToday(lastPlayedWord):
            viewState = .noWordToday(viewModel: finishedGameViewModelFactory.make(for: lastPlayedWord))
        }

        latestFetchResult = result
    }

    func observeGameFinished() async {
        for await _ in finishGameRelay.events {
            refresh()
        }
    }

    // MARK: - Privates

    @ObservationIgnored private let wordProviderUseCase: WordProviderUseCaseType
    @ObservationIgnored private let ongoingGameViewModelFactory: OngoingGameViewModelFactoryType
    @ObservationIgnored private let finishedGameViewModelFactory: FinishedGameViewModelFactoryType
    @ObservationIgnored private let finishGameRelay: FinishGameRelayType
    @ObservationIgnored private let modalCoordinator: ModalCoordinatorType
    @ObservationIgnored private let navigationRouter: NavigationRouterType

    @ObservationIgnored private var latestFetchResult: FetchWordModel?
}

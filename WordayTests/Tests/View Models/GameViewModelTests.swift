import Testing
import SwiftUI
import Foundation
@testable import Worday

struct GameViewModelTests {
    let sut: GameViewModel
    let mockWordProviderUseCase: WordProviderUseCaseMock
    let mockOngoingGameViewModelFactory: OngoingGameViewModelFactoryMock
    let mockFinishedGameViewModelFactory: FinishedGameViewModelFactoryMock
    let mockFinishGameRelay: FinishGameRelayMock
    let mockModalCoordinator: ModalCoordinatorMock
    let mockNavigationRouter: NavigationRouterMock

    init() {
        mockWordProviderUseCase = .init()
        mockOngoingGameViewModelFactory = .init()
        mockFinishedGameViewModelFactory = .init()
        mockFinishGameRelay = .init()
        mockModalCoordinator = .init()
        mockNavigationRouter = .init()

        sut = .init(
            wordProviderUseCase: mockWordProviderUseCase,
            ongoingGameViewModelFactory: mockOngoingGameViewModelFactory,
            finishedGameViewModelFactory: mockFinishedGameViewModelFactory,
            finishGameRelay: mockFinishGameRelay,
            modalCoordinator: mockModalCoordinator,
            navigationRouter: mockNavigationRouter
        )
    }

    @Test("refresh builds the ongoing-game state when there is a word")
    func refreshCreatesGameState() {
        mockWordProviderUseCase.fetchReturnValue = .word(word: "abcde")
        sut.refresh()
        #expect(mockOngoingGameViewModelFactory.calls == [.make(word: "abcde")])
        #expect(mockFinishedGameViewModelFactory.calls.isEmpty)
        #expect(sut.viewState.isGame)
    }

    @Test("refresh builds the finished state when today is already played")
    func refreshCreatesFinishedState() {
        mockWordProviderUseCase.fetchReturnValue = .noWordToday(lastPlayedWord: "abcde")
        sut.refresh()
        #expect(mockOngoingGameViewModelFactory.calls.isEmpty)
        #expect(mockFinishedGameViewModelFactory.calls == [.make(word: "abcde")])
        #expect(sut.viewState.isNotGameToday)
    }

    @Test("refresh builds the error state when fetching fails")
    func refreshCreatesErrorState() {
        mockWordProviderUseCase.fetchReturnValue = .error
        sut.refresh()
        #expect(mockOngoingGameViewModelFactory.calls.isEmpty)
        #expect(mockFinishedGameViewModelFactory.calls.isEmpty)
        #expect(sut.viewState == .error)
    }

    @Test("refresh dedupes an unchanged fetch result")
    func refreshDedupesUnchangedResult() {
        mockWordProviderUseCase.fetchReturnValue = .noWordToday(lastPlayedWord: "abcde")
        sut.refresh()
        sut.refresh()
        #expect(mockFinishedGameViewModelFactory.calls == [.make(word: "abcde")])
    }

    @Test("a game-finished event re-fetches the day's state")
    func gameFinishedEventRefetches() async {
        mockWordProviderUseCase.fetchReturnValue = .noWordToday(lastPlayedWord: "abcde")
        mockFinishGameRelay.finishGame()
        mockFinishGameRelay.finishStream()

        await sut.observeGameFinished()

        #expect(mockFinishedGameViewModelFactory.calls == [.make(word: "abcde")])
        #expect(sut.viewState.isNotGameToday)
    }

    @Test("setting the modal destination presents it through the coordinator")
    func presentsInfoModal() {
        sut.modalDestination = .info(.init(topics: [], versionString: ""))
        #expect(mockModalCoordinator.calls == [.present(destination: .info(.init(topics: [], versionString: "")))])
    }

    @Test("the navigation path is projected from the router")
    func navigationPathProxiesRouter() {
        sut.navigationPath = NavigationPath([NavigationDestination.none])
        #expect(mockNavigationRouter.calls == [.setPath(path: NavigationPath([NavigationDestination.none]))])
    }
}

private extension GameViewState {
    var isGame: Bool {
        switch self {
        case .game: return true
        case .empty, .error, .noWordToday: return false
        }
    }

    var isNotGameToday: Bool {
        switch self {
        case .empty, .error, .game: return false
        case .noWordToday: return true
        }
    }
}

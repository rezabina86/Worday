import Combine
import Testing
import Foundation
@testable import Worday

final class GameViewModelTests {
    let sut: GameViewModel!
    let mockWordProviderUseCase: WordProviderUseCaseMock
    let mockOngoingGameViewModelFactory: OngoingGameViewModelFactoryMock
    let mockFinishedGameViewModelFactory: FinishedGameViewModelFactoryMock
    let mockScenePhaseObserver: ScenePhaseObserverMock
    let mockAppTriggerFactory: AppTriggerFactoryMock
    let mockModalCoordinator: ModalCoordinatorMock
    let mockNavigationRouter: NavigationRouterMock
    
    var cancellables: Set<AnyCancellable>
    var viewState: GameViewState?
    
    init() {
        cancellables = []
        mockWordProviderUseCase = .init()
        mockOngoingGameViewModelFactory = .init()
        mockFinishedGameViewModelFactory = .init()
        mockScenePhaseObserver = .init()
        mockAppTriggerFactory = .init()
        mockModalCoordinator = .init()
        mockNavigationRouter = .init()
        
        sut = .init(
            wordProviderUseCase: mockWordProviderUseCase,
            ongoingGameViewModelFactory: mockOngoingGameViewModelFactory,
            finishedGameViewModelFactory: mockFinishedGameViewModelFactory,
            scenePhaseObserver: mockScenePhaseObserver,
            appTriggerFactory: mockAppTriggerFactory,
            modalCoordinator: mockModalCoordinator,
            navigationRouter: mockNavigationRouter
        )
        
        sut.viewState
            .sink { [weak self] state in
                self?.viewState = state
            }
            .store(in: &cancellables)
    }
    
    @Test func testCreateWithWord() async throws {
        mockWordProviderUseCase.fetchReturnValue = .word(word: "abcde")
        mockAppTriggerFactory.triggerRelay.send(())
        #expect(mockOngoingGameViewModelFactory.calls == [.create(word: "abcde")])
        #expect(mockFinishedGameViewModelFactory.calls.isEmpty)
        #expect(viewState?.isGame ?? false)
    }
    
    @Test func testCreateWithoutWord() async throws {
        mockWordProviderUseCase.fetchReturnValue = .noWordToday(lastPlayedWord: "abcde")
        mockAppTriggerFactory.triggerRelay.send(())
        #expect(mockOngoingGameViewModelFactory.calls.isEmpty)
        #expect(mockFinishedGameViewModelFactory.calls == [.create(word: "abcde")])
        #expect(viewState?.isNotGameToday ?? false)
    }
    
    @Test func testCreateWithError() async throws {
        mockWordProviderUseCase.fetchReturnValue = .error
        mockAppTriggerFactory.triggerRelay.send(())
        #expect(mockOngoingGameViewModelFactory.calls.isEmpty)
        #expect(mockFinishedGameViewModelFactory.calls.isEmpty)
        #expect(viewState == .error)
    }
    
    @Test func testPresentInfoModal() async throws {
        sut.setModalDestination(.info(.init(topics: [], versionString: "")))
        #expect(mockModalCoordinator.calls == [.present(destination: .info(.init(topics: [], versionString: "")))])
    }
    
    @Test func testPhaseChanged() async throws {
        sut.scenePhaseChanged(.active)
        #expect(mockScenePhaseObserver.calls == [.phaseChanged(scenePhase: .active)])
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

import Combine
import Testing
import Foundation
@testable import Worday

final class OngoingGameViewModelTests {
    let sut: OngoingGameViewModel!
    let mockWordProviderUseCase: WordProviderUseCaseMock
    let mockArrayShuffle: ArrayShuffleMock
    let mockModalCoordinator: ModalCoordinatorMock
    let mockAttemptTrackerUseCase: AttemptTrackerUseCaseMock
    let mockInfoModalViewStateConverter: InfoModalViewStateConverterMock
    
    var cancellables: Set<AnyCancellable>
    var viewState: GameViewState.OngoingGameViewState?
    
    init() {
        cancellables = []
        mockWordProviderUseCase = .init()
        mockArrayShuffle = .init()
        mockModalCoordinator = .init()
        mockAttemptTrackerUseCase = .init()
        mockArrayShuffle.shuffleReturnValue = ["a", "b", "c", "d", "e"]
        mockAttemptTrackerUseCase.numberOfTriesSubject.send(1)
        mockInfoModalViewStateConverter = .init()
        sut = .init(word: "abcde",
                    wordProviderUseCase: mockWordProviderUseCase,
                    arrayShuffle: mockArrayShuffle,
                    modalCoordinator: mockModalCoordinator,
                    attemptTrackerUseCase: mockAttemptTrackerUseCase,
                    infoModalViewStateConverter: mockInfoModalViewStateConverter)
        
        sut.viewState
            .sink { [weak self] state in
                self?.viewState = state
            }
            .store(in: &cancellables)
    }

    @Test func testCreateInitialViewState() async throws {
        let expectedState: GameViewState.OngoingGameViewState = .init(
            characters: [
                .empty(id: "0"),
                .empty(id: "1"),
                .empty(id: "2"),
                .empty(id: "3"),
                .empty(id: "4")
            ],
            numberOfTries: 1,
            keyboardViewState: .init(
                keys: [.init(id: "0", character: "a", onTap: .fake),
                       .init(id: "1", character: "b", onTap: .fake),
                       .init(id: "2", character: "c", onTap: .fake),
                       .init(id: "3", character: "d", onTap: .fake),
                       .init(id: "4", character: "e", onTap: .fake)],
                onTapEnter: .fake,
                onTapDelete: .fake
            ),
            onTapInfoButton: .fake
        )
        
        #expect(viewState == expectedState)
    }
    
    @Test func testTapOnTheFirstKey() async throws {
        viewState?.onTapFirstKey?.action()
        
        let expectedState: GameViewState.OngoingGameViewState = .init(
            characters: [
                .init(id: "0", state: .draft(char: "a")),
                .empty(id: "1"),
                .empty(id: "2"),
                .empty(id: "3"),
                .empty(id: "4")
            ],
            numberOfTries: 1,
            keyboardViewState: .init(
                keys: [.init(id: "0", character: "a", onTap: .fake),
                       .init(id: "1", character: "b", onTap: .fake),
                       .init(id: "2", character: "c", onTap: .fake),
                       .init(id: "3", character: "d", onTap: .fake),
                       .init(id: "4", character: "e", onTap: .fake)],
                onTapEnter: .fake,
                onTapDelete: .fake
            ),
            onTapInfoButton: .fake
        )
        
        #expect(viewState == expectedState)
    }
    
    @Test func testTapOnTheFirstKeyTwice() async throws {
        viewState?.onTapFirstKey?.action()
        viewState?.onTapFirstKey?.action()
        
        let expectedState: GameViewState.OngoingGameViewState = .init(
            characters: [
                .init(id: "0", state: .draft(char: "a")),
                .init(id: "1", state: .draft(char: "a")),
                .empty(id: "2"),
                .empty(id: "3"),
                .empty(id: "4")
            ],
            numberOfTries: 1,
            keyboardViewState: .init(
                keys: [.init(id: "0", character: "a", onTap: .fake),
                       .init(id: "1", character: "b", onTap: .fake),
                       .init(id: "2", character: "c", onTap: .fake),
                       .init(id: "3", character: "d", onTap: .fake),
                       .init(id: "4", character: "e", onTap: .fake)],
                onTapEnter: .fake,
                onTapDelete: .fake
            ),
            onTapInfoButton: .fake
        )
        
        #expect(viewState == expectedState)
    }
    
    @Test func testTapOnDelete() async throws {
        viewState?.onTapFirstKey?.action()
        viewState?.onTapFirstKey?.action()
        viewState?.keyboardViewState.onTapDelete.action()
        
        let expectedState: GameViewState.OngoingGameViewState = .init(
            characters: [
                .init(id: "0", state: .draft(char: "a")),
                .empty(id: "1"),
                .empty(id: "2"),
                .empty(id: "3"),
                .empty(id: "4")
            ],
            numberOfTries: 1,
            keyboardViewState: .init(
                keys: [.init(id: "0", character: "a", onTap: .fake),
                       .init(id: "1", character: "b", onTap: .fake),
                       .init(id: "2", character: "c", onTap: .fake),
                       .init(id: "3", character: "d", onTap: .fake),
                       .init(id: "4", character: "e", onTap: .fake)],
                onTapEnter: .fake,
                onTapDelete: .fake
            ),
            onTapInfoButton: .fake
        )
        
        #expect(viewState == expectedState)
    }
    
    @Test func testEnterWithWrongGuess() async throws {
        viewState?.onTapFirstKey?.action()
        viewState?.onTapFirstKey?.action()
        viewState?.onTapFirstKey?.action()
        viewState?.onTapFirstKey?.action()
        viewState?.onTapFirstKey?.action()
        
        viewState?.keyboardViewState.onTapEnter.action()
        
        let expectedState: GameViewState.OngoingGameViewState = .init(
            characters: [
                .init(id: "0", state: .correct(char: "a")),
                .init(id: "1", state: .misplaced(char: "a")),
                .init(id: "2", state: .misplaced(char: "a")),
                .init(id: "3", state: .misplaced(char: "a")),
                .init(id: "4", state: .misplaced(char: "a"))
            ],
            numberOfTries: 1,
            keyboardViewState: .init(
                keys: [.init(id: "0", character: "a", onTap: .fake),
                       .init(id: "1", character: "b", onTap: .fake),
                       .init(id: "2", character: "c", onTap: .fake),
                       .init(id: "3", character: "d", onTap: .fake),
                       .init(id: "4", character: "e", onTap: .fake)],
                onTapEnter: .fake,
                onTapDelete: .fake
            ),
            onTapInfoButton: .fake
        )
        
        #expect(viewState == expectedState)
        #expect(mockWordProviderUseCase.calls.isEmpty)
    }
    
    @Test func testEnterWithCorrectGuess() async throws {
        viewState?.onTapFirstKey?.action()
        viewState?.onTapSecondKey?.action()
        viewState?.onTapThirdKey?.action()
        viewState?.onTapFourthKey?.action()
        viewState?.onTapFifthKey?.action()
        
        viewState?.keyboardViewState.onTapEnter.action()
        
        let expectedState: GameViewState.OngoingGameViewState = .init(
            characters: [
                .init(id: "0", state: .correct(char: "a")),
                .init(id: "1", state: .correct(char: "b")),
                .init(id: "2", state: .correct(char: "c")),
                .init(id: "3", state: .correct(char: "d")),
                .init(id: "4", state: .correct(char: "e"))
            ],
            numberOfTries: 1,
            keyboardViewState: .init(
                keys: [.init(id: "0", character: "a", onTap: .fake),
                       .init(id: "1", character: "b", onTap: .fake),
                       .init(id: "2", character: "c", onTap: .fake),
                       .init(id: "3", character: "d", onTap: .fake),
                       .init(id: "4", character: "e", onTap: .fake)],
                onTapEnter: .fake,
                onTapDelete: .fake
            ),
            onTapInfoButton: .fake
        )
        
        #expect(viewState == expectedState)
        #expect(mockWordProviderUseCase.calls == [.store(word: "abcde")])
    }
    
    @Test func testPresentInfoModal() async throws {
        mockInfoModalViewStateConverter.createReturnValue = .init(topics: [], versionString: "")
        viewState?.onTapInfoButton.action()
        #expect(mockModalCoordinator.calls == [.present(destination: .info(.init(topics: [], versionString: "")))])
    }
    
    @Test func testAdvaceAttempTracker() async throws {
        viewState?.onTapFirstKey?.action()
        viewState?.onTapSecondKey?.action()
        viewState?.onTapThirdKey?.action()
        viewState?.onTapFourthKey?.action()
        viewState?.onTapFifthKey?.action()
        
        viewState?.keyboardViewState.onTapEnter.action()
        #expect(mockAttemptTrackerUseCase.calls == [.advance])
    }
}

private extension GameViewState.OngoingGameViewState {
    
    var onTapFirstKey: UserAction? {
        self.keyboardViewState.keys.first?.onTap
    }
    
    var onTapSecondKey: UserAction? {
        self.keyboardViewState.keys.first(where: { $0.id == "1" })?.onTap
    }
    
    var onTapThirdKey: UserAction? {
        self.keyboardViewState.keys.first(where: { $0.id == "2" })?.onTap
    }
    
    var onTapFourthKey: UserAction? {
        self.keyboardViewState.keys.first(where: { $0.id == "3" })?.onTap
    }
    
    var onTapFifthKey: UserAction? {
        self.keyboardViewState.keys.first(where: { $0.id == "4" })?.onTap
    }
}

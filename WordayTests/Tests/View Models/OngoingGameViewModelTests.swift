import Combine
import Testing
import Foundation
@testable import Worday

final class OngoingGameViewModelTests {
    var sut: OngoingGameViewModel!
    var mockWordProviderUseCase: WordProviderUseCaseMock
    var mockArrayShuffle: ArrayShuffleMock
    var mockModalCoordinator: ModalCoordinatorMock
    
    var cancellables: Set<AnyCancellable>
    var viewState: GameViewState.OngoingGameViewState?
    
    init() {
        cancellables = []
        mockWordProviderUseCase = .init()
        mockArrayShuffle = .init()
        mockModalCoordinator = .init()
        mockArrayShuffle.shuffleReturnValue = ["a", "b", "c", "d", "e"]
        sut = .init(word: "abcde",
                    wordProviderUseCase: mockWordProviderUseCase,
                    arrayShuffle: mockArrayShuffle,
                    modalCoordinator: mockModalCoordinator)
        
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
        viewState?.onTapInfoButton.action()
        #expect(mockModalCoordinator.calls == [.present(destination: .info)])
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

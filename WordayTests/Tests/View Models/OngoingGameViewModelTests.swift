import Testing
import Foundation
@testable import Worday

struct OngoingGameViewModelTests {
    let sut: OngoingGameViewModel
    let mockWordProviderUseCase: WordProviderUseCaseMock
    let mockArrayShuffle: ArrayShuffleMock
    let mockModalCoordinator: ModalCoordinatorMock
    let mockAttemptTrackerUseCase: AttemptTrackerUseCaseMock
    let mockInfoModalViewStateConverter: InfoModalViewStateConverterMock

    private var viewState: GameViewState.OngoingGameViewState { sut.viewState }

    init() {
        mockWordProviderUseCase = .init()
        mockArrayShuffle = .init()
        mockModalCoordinator = .init()
        mockAttemptTrackerUseCase = .init()
        mockArrayShuffle.shuffleReturnValue = ["a", "b", "c", "d", "e"]
        mockAttemptTrackerUseCase.numberOfTries = 1
        mockInfoModalViewStateConverter = .init()
        sut = .init(word: "abcde",
                    wordProviderUseCase: mockWordProviderUseCase,
                    arrayShuffle: mockArrayShuffle,
                    modalCoordinator: mockModalCoordinator,
                    attemptTrackerUseCase: mockAttemptTrackerUseCase,
                    infoModalViewStateConverter: mockInfoModalViewStateConverter)
    }

    @Test func createsInitialViewState() {
        #expect(viewState == makeExpectedState(characters: [
            .empty(id: "0"), .empty(id: "1"), .empty(id: "2"), .empty(id: "3"), .empty(id: "4")
        ]))
    }

    @Test func tapsOnTheFirstKey() {
        viewState.onTapFirstKey?.action()

        #expect(viewState == makeExpectedState(characters: [
            .init(id: "0", state: .draft(char: "a")),
            .empty(id: "1"), .empty(id: "2"), .empty(id: "3"), .empty(id: "4")
        ]))
    }

    @Test func tapsOnTheFirstKeyTwice() {
        viewState.onTapFirstKey?.action()
        viewState.onTapFirstKey?.action()

        #expect(viewState == makeExpectedState(characters: [
            .init(id: "0", state: .draft(char: "a")),
            .init(id: "1", state: .draft(char: "a")),
            .empty(id: "2"), .empty(id: "3"), .empty(id: "4")
        ]))
    }

    @Test func tapsOnDelete() {
        viewState.onTapFirstKey?.action()
        viewState.onTapFirstKey?.action()
        viewState.keyboardViewState.onTapDelete.action()

        #expect(viewState == makeExpectedState(characters: [
            .init(id: "0", state: .draft(char: "a")),
            .empty(id: "1"), .empty(id: "2"), .empty(id: "3"), .empty(id: "4")
        ]))
    }

    @Test func entersWithWrongGuess() {
        viewState.onTapFirstKey?.action()
        viewState.onTapFirstKey?.action()
        viewState.onTapFirstKey?.action()
        viewState.onTapFirstKey?.action()
        viewState.onTapFirstKey?.action()

        viewState.keyboardViewState.onTapEnter.action()

        #expect(viewState == makeExpectedState(characters: [
            .init(id: "0", state: .correct(char: "a")),
            .init(id: "1", state: .misplaced(char: "a")),
            .init(id: "2", state: .misplaced(char: "a")),
            .init(id: "3", state: .misplaced(char: "a")),
            .init(id: "4", state: .misplaced(char: "a"))
        ]))
        #expect(mockWordProviderUseCase.calls.isEmpty)
    }

    @Test func entersWithCorrectGuess() {
        tapEachKeyInOrder()

        viewState.keyboardViewState.onTapEnter.action()

        #expect(viewState == makeExpectedState(characters: [
            .init(id: "0", state: .correct(char: "a")),
            .init(id: "1", state: .correct(char: "b")),
            .init(id: "2", state: .correct(char: "c")),
            .init(id: "3", state: .correct(char: "d")),
            .init(id: "4", state: .correct(char: "e"))
        ]))
        #expect(mockWordProviderUseCase.calls == [.store(word: "abcde")])
    }

    @Test func presentsInfoModal() {
        mockInfoModalViewStateConverter.makeReturnValue = .init(topics: [], versionString: "")
        viewState.onTapInfoButton.action()
        #expect(mockModalCoordinator.calls == [.present(destination: .info(.init(topics: [], versionString: "")))])
    }

    @Test func advancesTheAttemptTrackerOnEnter() {
        tapEachKeyInOrder()

        viewState.keyboardViewState.onTapEnter.action()
        #expect(mockAttemptTrackerUseCase.calls == [.advance])
    }

    // MARK: - Helpers

    private func tapEachKeyInOrder() {
        viewState.onTapFirstKey?.action()
        viewState.onTapSecondKey?.action()
        viewState.onTapThirdKey?.action()
        viewState.onTapFourthKey?.action()
        viewState.onTapFifthKey?.action()
    }

    private func makeExpectedState(
        characters: [GameViewState.OngoingGameViewState.Character]
    ) -> GameViewState.OngoingGameViewState {
        .init(
            characters: characters,
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
    }
}

private extension GameViewState.OngoingGameViewState {

    var onTapFirstKey: UserAction? {
        keyboardViewState.keys.first?.onTap
    }

    var onTapSecondKey: UserAction? {
        keyboardViewState.keys.first(where: { $0.id == "1" })?.onTap
    }

    var onTapThirdKey: UserAction? {
        keyboardViewState.keys.first(where: { $0.id == "2" })?.onTap
    }

    var onTapFourthKey: UserAction? {
        keyboardViewState.keys.first(where: { $0.id == "3" })?.onTap
    }

    var onTapFifthKey: UserAction? {
        keyboardViewState.keys.first(where: { $0.id == "4" })?.onTap
    }
}

import Testing
import Foundation
@testable import Worday

struct FinishedGameViewModelTests {
    let sut: FinishedGameViewModel

    let mockDictionaryUseCase: DictionaryUseCaseMock
    let mockStreakUseCase: StreakUseCaseMock
    let mockAttemptTrackerUseCase: AttemptTrackerUseCaseMock
    let mockWordListViewStateConverter: WordListViewStateConverterMock
    let mockNavigationRouter: NavigationRouterMock

    init() {
        mockDictionaryUseCase = .init()
        mockStreakUseCase = .init()
        mockAttemptTrackerUseCase = .init()
        mockWordListViewStateConverter = .init()
        mockNavigationRouter = .init()

        mockAttemptTrackerUseCase.ordinalStringReturnValue = "1st"
        mockAttemptTrackerUseCase.feedbackMessageReturnValue = "Great job! 🎉"
        mockStreakUseCase.calculateStreakReturnValue = 1
        mockStreakUseCase.totalPlayedReturnValue = 2

        sut = .init(word: "abcde",
                    dictionaryUseCase: mockDictionaryUseCase,
                    streakUseCase: mockStreakUseCase,
                    attemptTrackerUseCase: mockAttemptTrackerUseCase,
                    wordListViewStateConverter: mockWordListViewStateConverter,
                    navigationRouter: mockNavigationRouter)
    }

    @Test("it shows the loading state before the meaning is loaded")
    func loadingState() {
        #expect(sut.viewState == makeExpectedState(meaning: .loading))

        sut.viewState.allWordButton.onTap.action()
        #expect(mockWordListViewStateConverter.calls == [.make])
    }

    @Test("it shows the error state when the lookup fails")
    func errorState() async {
        mockDictionaryUseCase.meaningReturnValue = .error

        await sut.load()

        #expect(sut.viewState == makeExpectedState(
            meaning: .error(message: "You’ve solved today’s puzzle. The word was", word: "ABCDE")
        ))
        #expect(mockDictionaryUseCase.calls == [.meaning(word: "abcde")])

        sut.viewState.allWordButton.onTap.action()
        #expect(mockWordListViewStateConverter.calls == [.make])
    }

    @Test("it shows the loaded state with the first meaning selected by default")
    func loadedState() async {
        mockDictionaryUseCase.meaningReturnValue = .data(.fake())

        await sut.load()

        let expectedMeaning = FinishedGameViewState.Meaning.MeaningViewState.Meaning(
            id: "0",
            type: "noun",
            definitions: [.init(id: "0", index: 1, definition: "definition")]
        )
        #expect(sut.viewState == makeExpectedState(meaning: .meaning(viewState: .init(
            word: "WORD",
            meanings: [expectedMeaning],
            selectedMeaning: expectedMeaning,
            onSelectMeaning: { _ in }
        ))))

        sut.viewState.allWordButton.onTap.action()
        #expect(mockWordListViewStateConverter.calls == [.make])
    }

    @Test("selecting a meaning updates the selection")
    func selectsMeaning() async {
        mockDictionaryUseCase.meaningReturnValue = .data(.fake())
        await sut.load()

        guard case let .meaning(viewState) = sut.viewState.meaning else {
            Issue.record("expected a loaded meaning state")
            return
        }

        let other = FinishedGameViewState.Meaning.MeaningViewState.Meaning(id: "9", type: "verb", definitions: [])
        viewState.onSelectMeaning(other)

        guard case let .meaning(updated) = sut.viewState.meaning else {
            Issue.record("expected a loaded meaning state")
            return
        }
        #expect(updated.selectedMeaning == other)
    }

    // MARK: - Helpers

    private func makeExpectedState(meaning: FinishedGameViewState.Meaning) -> FinishedGameViewState {
        .init(
            allWordButton: .init(title: "All words", onTap: .fake),
            title: "Great job! 🎉",
            scoreString: "You solved it on your 1st try",
            currentStreak: .init(title: "Current streak", value: 1),
            totalPlayed: .init(title: "Played", value: 2),
            meaning: meaning,
            subtitle: "Come back tomorrow for another challenge!"
        )
    }
}

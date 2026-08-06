import Testing
import Foundation
@testable import Worday

struct WordMeaningViewModelTests {
    let sut: WordMeaningViewModel
    let mockDictionaryUseCase: DictionaryUseCaseMock
    let mockAlertRouter: AlertRouterMock

    init() {
        mockDictionaryUseCase = .init()
        mockAlertRouter = .init()
        sut = .init(word: "abcde", dictionaryUseCase: mockDictionaryUseCase, alertRouter: mockAlertRouter)
    }

    @Test("it presents a retry alert when the meaning fails to load")
    func presentsRetryAlertOnError() async {
        mockDictionaryUseCase.meaningReturnValue = .error

        await sut.load()

        #expect(mockAlertRouter.presented?.buttons.map(\.title) == ["Retry", "OK"])
    }

    @Test("the retry button re-loads the meaning")
    func retryReloadsTheMeaning() async {
        mockDictionaryUseCase.meaningReturnValue = .error
        await sut.load()
        #expect(mockDictionaryUseCase.calls == [.meaning(word: "abcde")])

        mockAlertRouter.presented?.buttons.first?.onTap.action()   // Retry
        for _ in 0..<100 where mockDictionaryUseCase.calls.count < 2 { await Task.yield() }

        #expect(mockDictionaryUseCase.calls == [.meaning(word: "abcde"), .meaning(word: "abcde")])
    }

    @Test("it does not present an alert on success")
    func noAlertOnSuccess() async {
        mockDictionaryUseCase.meaningReturnValue = .data(.fake())

        await sut.load()

        #expect(mockAlertRouter.calls == [])
    }

    @Test("it shows the loading state before the meaning is loaded")
    func showsLoadingInitially() {
        #expect(sut.viewState == .loading)
    }

    @Test("it shows the error state when the lookup fails")
    func showsErrorOnFailure() async {
        mockDictionaryUseCase.meaningReturnValue = .error

        await sut.load()

        #expect(sut.viewState == .error(
            message: "There was an error loading the word. The word is",
            word: "ABCDE"
        ))
        #expect(mockDictionaryUseCase.calls == [.meaning(word: "abcde")])
    }

    @Test("it shows the loaded state with the first meaning selected by default")
    func showsMeaningWithDefaultSelection() async {
        mockDictionaryUseCase.meaningReturnValue = .data(.fake())

        await sut.load()

        let expectedMeaning = WordMeaningViewState.MeaningViewState.Meaning(
            id: "0",
            type: "noun",
            definitions: [.init(id: "0", index: 1, definition: "definition")]
        )
        #expect(sut.viewState == .meaning(viewState: .init(
            word: "WORD",
            meanings: [expectedMeaning],
            selectedMeaning: expectedMeaning,
            onSelectMeaning: { _ in }
        )))
    }

    @Test("selecting a meaning updates the selection")
    func selectsMeaning() async {
        mockDictionaryUseCase.meaningReturnValue = .data(.fake())
        await sut.load()

        guard case let .meaning(viewState) = sut.viewState else {
            Issue.record("expected a loaded meaning state")
            return
        }

        let other = WordMeaningViewState.MeaningViewState.Meaning(id: "9", type: "verb", definitions: [])
        viewState.onSelectMeaning(other)

        guard case let .meaning(updated) = sut.viewState else {
            Issue.record("expected a loaded meaning state")
            return
        }
        #expect(updated.selectedMeaning == other)
    }
}

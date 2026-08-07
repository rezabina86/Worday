import Testing
import Foundation
@testable import Worday

struct PlayedWordsLibraryTests {
    let sut: PlayedWordsLibrary
    let mockWordContext: WordStorageModelContextMock

    init() {
        mockWordContext = .init()
        sut = .init(wordContext: mockWordContext)
    }

    @Test("reload reads the stored words from the context")
    func reloadReadsFromStore() {
        mockWordContext.fetchReturnValue = [
            .init(id: .init(rawValue: "1"), word: "CAT", playedAt: .init(timeIntervalSince1970: 0))
        ]

        sut.reload()

        #expect(sut.words.map(\.word) == ["CAT"])
        #expect(mockWordContext.calls == [.fetchAll])
    }

    @Test("reload refreshes the words from the context")
    func reloadRefreshesFromStore() {
        mockWordContext.fetchReturnValue = []
        sut.reload()
        #expect(sut.words.isEmpty)

        mockWordContext.fetchReturnValue = [
            .init(id: .init(rawValue: "1"), word: "DOG", playedAt: .init(timeIntervalSince1970: 0))
        ]
        sut.reload()

        #expect(sut.words.map(\.word) == ["DOG"])
    }

    @Test("reload keeps the last-known-good words when the fetch fails")
    func reloadKeepsLastKnownGoodOnError() {
        mockWordContext.fetchReturnValue = [
            .init(id: .init(rawValue: "1"), word: "CAT", playedAt: .init(timeIntervalSince1970: 0))
        ]
        sut.reload()
        #expect(sut.words.map(\.word) == ["CAT"])

        mockWordContext.fetchAllThrows = WordStorageModelContextMock.StubError.failed
        sut.reload()

        // The transient read error must not blank the history the UI is showing.
        #expect(sut.words.map(\.word) == ["CAT"])
    }
}

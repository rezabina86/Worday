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

    @Test("load reads the stored words from the context")
    func loadReadsFromStore() {
        mockWordContext.fetchReturnValue = [
            .init(id: "1", word: "CAT", playedAt: .init(timeIntervalSince1970: 0))
        ]

        sut.load()

        #expect(sut.words.map(\.word) == ["CAT"])
        #expect(mockWordContext.calls == [.fetchAll])
    }

    @Test("reload refreshes the words from the context")
    func reloadRefreshesFromStore() {
        mockWordContext.fetchReturnValue = []
        sut.load()
        #expect(sut.words.isEmpty)

        mockWordContext.fetchReturnValue = [
            .init(id: "1", word: "DOG", playedAt: .init(timeIntervalSince1970: 0))
        ]
        sut.reload()

        #expect(sut.words.map(\.word) == ["DOG"])
    }
}

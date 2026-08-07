import Testing
import Foundation
@testable import Worday

struct DictionaryRepositoryTests {

    var sut: DictionaryRepository
    var mockWordDatabase: WordDatabaseMock

    init() {
        mockWordDatabase = .init()
        sut = .init(wordDatabase: mockWordDatabase)
    }

    @Test func success() async throws {
        mockWordDatabase.meaningReturnValue = .fake()

        let result = try await sut.meaning(for: "abcde")
        #expect(result == .fake())
        #expect(mockWordDatabase.calls == [.meaning(word: "abcde")])
    }

    @Test func throwsWhenTheWordHasNoMeaning() async throws {
        mockWordDatabase.meaningReturnValue = nil

        await #expect(throws: DictionaryRepositoryError.noMeaning) {
            try await sut.meaning(for: "abcde")
        }
        #expect(mockWordDatabase.calls == [.meaning(word: "abcde")])
    }
}

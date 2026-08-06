import Testing
import Foundation
@testable import Worday

struct DictionaryUseCaseTests {
    let sut: DictionaryUseCase
    let mockRepository: DictionaryRepositoryMock

    init() {
        mockRepository = .init()
        sut = .init(dictionaryRepository: mockRepository)
    }

    @Test("it returns the data state when the repository succeeds")
    func returnsDataOnSuccess() async {
        mockRepository.meaningReturnValue = .fake(word: "cat")

        let result = await sut.meaning(for: "cat")

        #expect(result == .data(.fake(word: "cat")))
        #expect(mockRepository.calls == [.meaning(word: "cat")])
    }

    @Test("it returns the error state when the repository throws")
    func returnsErrorOnFailure() async {
        mockRepository.meaningThrows = CancellationError()

        let result = await sut.meaning(for: "cat")

        #expect(result == .error)
        #expect(mockRepository.calls == [.meaning(word: "cat")])
    }
}

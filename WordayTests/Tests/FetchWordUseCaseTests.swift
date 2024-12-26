import Testing
import Foundation
@testable import Worday

struct FetchWordUseCaseTests {
    
    var sut: FetchWordUseCase!
    var mockWordRepository: WordRepositoryMock!
    var mockWordContext: WordStorageModelContextMock!
    var mockRandomWordProducer: RandomWordProducerMock!
    
    init() {
        mockWordRepository = .init()
        mockWordContext = .init()
        mockRandomWordProducer = .init()
        sut = .init(
            wordRepository: mockWordRepository,
            wordContext: mockWordContext,
            randomWordProducer: mockRandomWordProducer
        )
    }

    @Test func testFetchSuccessfully() async throws {
        mockWordRepository.wordsReturnValue = .fake(words: ["a", "b"])
        mockWordContext.fetchReturnValue = []
        mockRandomWordProducer.randomElementReturnValue = "a"
        
        let word = try sut.fetch()
        #expect(word == "a")
        #expect(mockWordRepository.calls == [.words])
        #expect(mockWordContext.calls == [.fetchAll])
        #expect(mockRandomWordProducer.calls == [.randomElement(words: ["a", "b"])])
    }
    
    @Test func testFetchSuccessfullyWhenAllWordsCompleted() async throws {
        mockWordRepository.wordsReturnValue = .fake(words: ["a", "b"])
        mockWordContext.fetchReturnValue = [.init(id: "123", word: "a"), .init(id: "345", word: "b")]
        mockRandomWordProducer.randomElementReturnValue = "a"
        
        #expect(throws: FetchWordUseCaseError.noAvailableWords, performing: {
            try sut.fetch()
        })
        
        #expect(mockWordRepository.calls == [.words])
        #expect(mockWordContext.calls == [.fetchAll])
        #expect(mockRandomWordProducer.calls == [])
    }
    
    @Test func testFetchSuccessfullyWhenWordsPartiallyCompleted() async throws {
        mockWordRepository.wordsReturnValue = .fake(words: ["a", "b", "c", "d"])
        mockWordContext.fetchReturnValue = [.init(id: "123", word: "a"), .init(id: "345", word: "b")]
        mockRandomWordProducer.randomElementReturnValue = "c"
        
        let word = try sut.fetch()
        #expect(word == "c")
        #expect(mockWordRepository.calls == [.words])
        #expect(mockWordContext.calls == [.fetchAll])
        #expect(mockRandomWordProducer.calls == [.randomElement(words: ["c", "d"])])
    }
}

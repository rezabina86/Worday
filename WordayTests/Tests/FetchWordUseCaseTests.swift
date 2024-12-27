import Testing
import Foundation
@testable import Worday

struct FetchWordUseCaseTests {
    
    var sut: FetchWordUseCase!
    var mockWordRepository: WordRepositoryMock!
    var mockWordContext: WordStorageModelContextMock!
    var mockRandomWordProducer: RandomWordProducerMock!
    var mockDateService: DateServiceMock!
    
    init() {
        mockWordRepository = .init()
        mockWordContext = .init()
        mockRandomWordProducer = .init()
        mockDateService = .init()
        sut = .init(
            wordRepository: mockWordRepository,
            wordContext: mockWordContext,
            randomWordProducer: mockRandomWordProducer,
            dateService: mockDateService
        )
    }

    @Test func testFetchSuccessfully() async throws {
        mockWordRepository.wordsReturnValue = .fake(words: ["a", "b"])
        mockWordContext.fetchReturnValue = []
        mockRandomWordProducer.randomElementReturnValue = "a"
        mockDateService.isDateInTodayReturnValue = false
        
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
        mockDateService.isDateInTodayReturnValue = false
        
        #expect(throws: FetchWordUseCaseError.noAvailableWords, performing: {
            try sut.fetch()
        })
        
        #expect(mockWordRepository.calls == [.words])
        #expect(mockWordContext.calls == [.fetchAll])
        #expect(mockRandomWordProducer.calls == [])
    }
    
    @Test func testFetchTodayWordIsCompleted() async throws {
        mockWordRepository.wordsReturnValue = .fake(words: ["a", "b"])
        mockWordContext.fetchReturnValue = [.init(id: "123", word: "a"), .init(id: "345", word: "b")]
        mockRandomWordProducer.randomElementReturnValue = "a"
        mockDateService.isDateInTodayReturnValue = true
        
        #expect(throws: FetchWordUseCaseError.noWordToday, performing: {
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
        mockDateService.isDateInTodayReturnValue = false
        
        let word = try sut.fetch()
        #expect(word == "c")
        #expect(mockWordRepository.calls == [.words])
        #expect(mockWordContext.calls == [.fetchAll])
        #expect(mockRandomWordProducer.calls == [.randomElement(words: ["c", "d"])])
    }
}

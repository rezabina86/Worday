import Testing
import Foundation
@testable import Worday

struct WordProviderUseCaseTests {
    
    var sut: WordProviderUseCase
    var mockWordRepository: WordRepositoryMock
    var mockWordContext: WordStorageModelContextMock
    var mockRandomWordProducer: RandomWordProducerMock
    var mockDateService: DateServiceMock
    var mockUserSettings: UserSettingsMock
    var mockUUIDProvider: UUIDProviderMock
    var mockDateProvider: DateProviderMock
    
    init() {
        mockWordRepository = .init()
        mockWordContext = .init()
        mockRandomWordProducer = .init()
        mockDateService = .init()
        mockUserSettings = .init()
        mockUUIDProvider = .init()
        mockDateProvider = .init()
        sut = .init(
            wordRepository: mockWordRepository,
            wordContext: mockWordContext,
            randomWordProducer: mockRandomWordProducer,
            dateService: mockDateService,
            userSettings: mockUserSettings,
            uuidProvider: mockUUIDProvider,
            dateProvider: mockDateProvider
        )
    }
    
    @Test func testWhenThereIsUnplayedWord() async throws {
        mockUserSettings.currentWordReturnValue = "hello"
        mockWordRepository.wordsReturnValue = .fake(words: ["a", "b"])
        mockWordContext.fetchReturnValue = []
        mockRandomWordProducer.randomElementReturnValue = "a"
        mockDateService.isDateInTodayReturnValue = false
        
        let result = sut.fetch()
        #expect(result == .word(word: "hello"))
        #expect(mockWordRepository.calls.isEmpty)
        #expect(mockWordContext.calls.isEmpty)
        #expect(mockRandomWordProducer.calls.isEmpty)
        #expect(mockUserSettings.setCurrentWordCall.isEmpty)
    }

    @Test func testFetchSuccessfully() async throws {
        mockUserSettings.currentWordReturnValue = nil
        mockWordRepository.wordsReturnValue = .fake(words: ["a", "b"])
        mockWordContext.fetchReturnValue = []
        mockRandomWordProducer.randomElementReturnValue = "a"
        mockDateService.isDateInTodayReturnValue = false
        
        let result = sut.fetch()
        #expect(result == .word(word: "a"))
        #expect(mockWordRepository.calls == [.words])
        #expect(mockWordContext.calls == [.fetchAll])
        #expect(mockRandomWordProducer.calls == [.randomElement(words: ["a", "b"])])
        #expect(mockUserSettings.setCurrentWordCall == [.currentWord(.set("a"))])
    }
    
    @Test func testFetchSuccessfullyWhenAllWordsCompleted() async throws {
        mockUserSettings.currentWordReturnValue = nil
        mockWordRepository.wordsReturnValue = .fake(words: ["a", "b"])
        mockWordContext.fetchReturnValue = [
            .init(id: "123", word: "a", playedAt: .now),
            .init(id: "345", word: "b", playedAt: .now)
        ]
        mockRandomWordProducer.randomElementReturnValue = "a"
        mockDateService.isDateInTodayReturnValue = false
        
        let result = sut.fetch()
        
        #expect(result == .error)
        #expect(mockWordRepository.calls == [.words])
        #expect(mockWordContext.calls == [.fetchAll])
        #expect(mockRandomWordProducer.calls == [])
        #expect(mockUserSettings.setCurrentWordCall.isEmpty)
    }
    
    @Test func testFetchTodayWordIsCompleted() async throws {
        mockUserSettings.currentWordReturnValue = nil
        mockWordRepository.wordsReturnValue = .fake(words: ["a", "b"])
        mockWordContext.fetchReturnValue = [
            .init(id: "123", word: "a", playedAt: .now),
            .init(id: "345", word: "b", playedAt: .now)
        ]
        mockRandomWordProducer.randomElementReturnValue = "a"
        mockDateService.isDateInTodayReturnValue = true
        
        let result = sut.fetch()
        #expect(result == .noWordToday(lastPlayedWord: "a"))
        #expect(mockWordRepository.calls == [.words])
        #expect(mockWordContext.calls == [.fetchAll])
        #expect(mockRandomWordProducer.calls.isEmpty)
        #expect(mockUserSettings.setCurrentWordCall.isEmpty)
    }
    
    @Test func testFetchSuccessfullyWhenWordsPartiallyCompleted() async throws {
        mockUserSettings.currentWordReturnValue = nil
        mockWordRepository.wordsReturnValue = .fake(words: ["a", "b", "c", "d"])
        mockWordContext.fetchReturnValue = [
            .init(id: "123", word: "a", playedAt: .now),
            .init(id: "345", word: "b", playedAt: .now)
        ]
        mockRandomWordProducer.randomElementReturnValue = "c"
        mockDateService.isDateInTodayReturnValue = false
        
        let result = sut.fetch()
        #expect(result == .word(word: "c"))
        #expect(mockWordRepository.calls == [.words])
        #expect(mockWordContext.calls == [.fetchAll])
        #expect(mockRandomWordProducer.calls == [.randomElement(words: ["c", "d"])])
        #expect(mockUserSettings.setCurrentWordCall == [.currentWord(.set("c"))])
    }
    
    @Test func testStoreWord() async throws {
        let referenceDate = Date.fake(hour: 12, minute: 23, day: 2, month: 10, year: 2023)!
        mockDateProvider.nowReturnValue = referenceDate
        mockUUIDProvider.createReturnValue = "123"
        
        sut.store(word: "a")
        #expect(mockUserSettings.setCurrentWordCall == [.currentWord(.set(nil))])
        #expect(mockWordContext.calls == [.insert(model: .init(id: "123", word: "a", playedAt: referenceDate))])
    }
}

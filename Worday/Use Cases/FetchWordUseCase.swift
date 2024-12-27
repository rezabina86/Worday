import Foundation

enum FetchWordUseCaseError: Error {
    case noAvailableWords
    case noWordToday
}

protocol FetchWordUseCaseType {
    func fetch() throws -> String
}

final class FetchWordUseCase: FetchWordUseCaseType {
    
    init(
        wordRepository: WordRepositoryType,
        wordContext: WordStorageModelContextType,
        randomWordProducer: RandomWordProducerType,
        dateService: DateServiceType
    ) {
        self.wordRepository = wordRepository
        self.wordContext = wordContext
        self.randomWordProducer = randomWordProducer
        self.dateService = dateService
    }
    
    func fetch() throws -> String {
        try loadWordsIfNecessary()
        
        guard let allWords = words?.words else {
            throw FetchWordUseCaseError.noAvailableWords
        }
        
        let storedWords = try wordContext.fetchAll()
        
        if let firstWordDate = storedWords.first.map ({ $0.createdAt }),
           dateService.isDateInToday(firstWordDate) {
            throw FetchWordUseCaseError.noWordToday
        }
        
        // Storing words in Set to decrease time complexity
        let allWordsSet = Set(allWords)
        let storedWordsSet = Set(storedWords.map { $0.word })
        
        let availableWords = allWordsSet.subtracting(storedWordsSet)
        
        if availableWords.isEmpty {
            throw FetchWordUseCaseError.noAvailableWords
        }
        
        guard let word = randomWordProducer.randomElement(in: availableWords) else {
            throw FetchWordUseCaseError.noAvailableWords
        }
        
        return word
    }
    
    // MARK: - Privates
    private let wordRepository: WordRepositoryType
    private let wordContext: WordStorageModelContextType
    private let randomWordProducer: RandomWordProducerType
    private let dateService: DateServiceType
    
    private var words: WordModel?
    
    private func loadWordsIfNecessary() throws {
        guard words == nil else { return }
        self.words = try wordRepository.words()
    }
}

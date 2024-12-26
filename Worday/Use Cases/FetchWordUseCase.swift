import Foundation

enum FetchWordUseCaseError: Error {
    case noAvailableWords
}

protocol FetchWordUseCaseType {
    func fetch() throws -> String
}

final class FetchWordUseCase: FetchWordUseCaseType {
    
    init(
        wordRepository: WordRepositoryType,
        wordContext: WordStorageModelContextType,
        randomWordProducer: RandomWordProducerType
    ) {
        self.wordRepository = wordRepository
        self.wordContext = wordContext
        self.randomWordProducer = randomWordProducer
    }
    
    func fetch() throws -> String {
        try loadWordsIfNecessary()
        
        guard let allWords = words?.words else {
            throw FetchWordUseCaseError.noAvailableWords
        }
        
        let allWordsSet = Set(allWords)
        
        let storedWords = try Set(wordContext.fetchAll().map { $0.word })
        
        let availableWords = allWordsSet.subtracting(storedWords)
        
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
    
    private var words: WordModel?
    
    private func loadWordsIfNecessary() throws {
        guard words == nil else { return }
        self.words = try wordRepository.words()
    }
}

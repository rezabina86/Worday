import Combine
import Foundation

enum FetchWordModel: Equatable {
    case error
    case word(word: String)
    case noWordToday(lastPlayedWord: String)
}

protocol FetchWordUseCaseType {
    func fetch() -> FetchWordModel
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
    
    func fetch() -> FetchWordModel {
        guard let allWords = try? wordRepository.words().words else {
            return .error
        }
        
        guard let storedWords = try? wordContext.fetchAll() else {
            return .error
        }
        
        if let firstWord = storedWords.first,
           dateService.isDateInToday(firstWord.createdAt) {
            return .noWordToday(lastPlayedWord: firstWord.word)
        }
        
        // Storing words in Set to decrease time complexity
        let allWordsSet = Set(allWords)
        let storedWordsSet = Set(storedWords.map { $0.word })
        
        let availableWords = allWordsSet.subtracting(storedWordsSet)
        
        if availableWords.isEmpty {
            return .error
        }
        
        guard let word = randomWordProducer.randomElement(in: availableWords) else {
            return .error
        }
        
        return .word(word: word)
    }
    
    // MARK: - Privates
    private let wordRepository: WordRepositoryType
    private let wordContext: WordStorageModelContextType
    private let randomWordProducer: RandomWordProducerType
    private let dateService: DateServiceType
}

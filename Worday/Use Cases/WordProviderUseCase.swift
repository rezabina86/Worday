import Foundation

enum FetchWordModel: Equatable {
    case error
    case word(word: String)
    case noWordToday(lastPlayedWord: String)
}

protocol WordProviderUseCaseType {
    func fetch() -> FetchWordModel
    func store(word: String)
}

final class WordProviderUseCase: WordProviderUseCaseType {
    
    init(
        wordDatabase: WordDatabaseType,
        wordContext: WordStorageModelContextType,
        randomWordProducer: RandomWordProducerType,
        dateService: DateServiceType,
        userSettings: UserSettingsType,
        uuidProvider: UUIDProviderType,
        dateProvider: DateProviderType,
        finishGameRelay: FinishGameRelayType,
        attemptTrackerUseCase: AttemptTrackerUseCaseType,
        playedWordsLibrary: PlayedWordsLibraryType
    ) {
        self.wordDatabase = wordDatabase
        self.wordContext = wordContext
        self.randomWordProducer = randomWordProducer
        self.dateService = dateService
        self.userSettings = userSettings
        self.uuidProvider = uuidProvider
        self.dateProvider = dateProvider
        self.finishGameRelay = finishGameRelay
        self.attemptTrackerUseCase = attemptTrackerUseCase
        self.playedWordsLibrary = playedWordsLibrary
    }
    
    func fetch() -> FetchWordModel {
        if let currentWord = userSettings.currentWord {
            return .word(word: currentWord)
        }
        
        let allWords = wordDatabase.answerWords()
        guard !allWords.isEmpty else {
            return .error
        }

        guard let storedWords = try? wordContext.fetchAll() else {
            return .error
        }
        
        if let firstWord = storedWords.first,
           dateService.isDateInToday(firstWord.playedAt) {
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
        
        userSettings.currentWord = word
        attemptTrackerUseCase.cleanup()
        
        return .word(word: word)
    }
    
    func store(word: String) {
        wordContext.insert(
            .init(
                id: .init(rawValue: uuidProvider.create()),
                word: word,
                playedAt: dateProvider.now()
            )
        )
        try? wordContext.save()
        playedWordsLibrary.reload()
        userSettings.currentWord = nil
        finishGameRelay.finishGame()
    }
    
    // MARK: - Privates
    private let wordDatabase: WordDatabaseType
    private let wordContext: WordStorageModelContextType
    private let randomWordProducer: RandomWordProducerType
    private let dateService: DateServiceType
    private let userSettings: UserSettingsType
    private let uuidProvider: UUIDProviderType
    private let dateProvider: DateProviderType
    private let finishGameRelay: FinishGameRelayType
    private let attemptTrackerUseCase: AttemptTrackerUseCaseType
    private let playedWordsLibrary: PlayedWordsLibraryType
}

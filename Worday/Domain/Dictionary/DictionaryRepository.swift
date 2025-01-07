import Foundation

enum DictionaryRepositoryError: Error {
    case noMeaning
}

protocol DictionaryRepositoryType {
    func meaning(for word: String) async throws -> WordMeaningModel
}

struct DictionaryRepository: DictionaryRepositoryType {
    
    init(dictionaryService: DictionaryServiceType) {
        self.dictionaryService = dictionaryService
    }
    
    func meaning(for word: String) async throws -> WordMeaningModel {
        let apiEntity = try await dictionaryService.meaning(for: word)
        guard let firstMeaning = apiEntity.first else { throw  DictionaryRepositoryError.noMeaning }
        return WordMeaningModel(from: firstMeaning)
    }
    
    // MARK: - Privates
    private let dictionaryService: DictionaryServiceType
}

private extension WordMeaningModel {
    init(from apiEntity: WordMeaningAPIEntity) {
        self = .init(word: apiEntity.word,
                     meanings: apiEntity.meanings.map { .init(from: $0) } )
    }
}

private extension WordMeaningModel.Meaning {
    init(from apiEntity: WordMeaningAPIEntity.Meaning) {
        self = .init(partOfSpeech: .init(from: apiEntity.partOfSpeech),
                     definitions: apiEntity.definitions.map { .init(from: $0) })
    }
}

extension WordMeaningModel.Meaning.PartOfSpeech {
    init(from apiEntity: WordMeaningAPIEntity.Meaning.PartOfSpeech) {
        switch apiEntity {
        case .noun: self = .noun
        case .verb: self = .verb
        case .interjection: self = .interjection
        case .adjective: self = .adjective
        case .adverb: self = .adverb
        case .pronoun: self = .pronoun
        case .preposition: self = .preposition
        case .conjunction: self = .conjunction
        case .numeral: self = .numeral
        case .article: self = .article
        case .determiner: self = .determiner
        }
    }
}

extension WordMeaningModel.Meaning.Definition {
    init(from apiEntity: WordMeaningAPIEntity.Meaning.Definition) {
        self = .init(definition: apiEntity.definition)
    }
}

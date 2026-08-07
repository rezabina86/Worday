import Foundation

enum DictionaryRepositoryError: Error {
    case noMeaning
}

protocol DictionaryRepositoryType {
    func meaning(for word: String) async throws -> WordMeaningModel
}

struct DictionaryRepository: DictionaryRepositoryType {

    init(wordDatabase: WordDatabaseType) {
        self.wordDatabase = wordDatabase
    }

    func meaning(for word: String) async throws -> WordMeaningModel {
        guard let meaning = wordDatabase.meaning(for: word) else {
            throw DictionaryRepositoryError.noMeaning
        }
        return meaning
    }

    // MARK: - Privates
    private let wordDatabase: WordDatabaseType
}

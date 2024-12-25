import Foundation

struct WordModel: Equatable {
    let words: [String]
}

protocol WordRepositoryType {
    func words() throws -> WordModel
}

struct WordRepository: WordRepositoryType {
    
    init(wordService: WordServiceType) {
        self.wordService = wordService
    }
    
    func words() throws -> WordModel {
        let entity = try wordService.load()
        let wordModel = WordModel(from: entity)
        return wordModel
    }
    
    // MARK: - Privates
    private let wordService: WordServiceType
}

private extension WordModel {
    init(from entity: WordEntity) {
        self.init(words: entity.commonWords)
    }
}

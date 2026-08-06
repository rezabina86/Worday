import Foundation

enum DictionaryDataState: Equatable {
    case loading
    case error
    case data(WordMeaningModel)
}

protocol DictionaryUseCaseType {
    func meaning(for word: String) async -> DictionaryDataState
}

struct DictionaryUseCase: DictionaryUseCaseType {

    // MARK: - Life Cycle

    init(dictionaryRepository: DictionaryRepositoryType) {
        self.dictionaryRepository = dictionaryRepository
    }

    // MARK: - Publics

    func meaning(for word: String) async -> DictionaryDataState {
        do {
            let meaning = try await dictionaryRepository.meaning(for: word)
            return .data(meaning)
        } catch {
            return .error
        }
    }

    // MARK: - Privates

    private let dictionaryRepository: DictionaryRepositoryType
}

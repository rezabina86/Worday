import Combine
import Foundation

enum DictionaryDataState: Equatable {
    case loading
    case error
    case data(WordMeaningModel)
}

protocol DictionaryUseCaseType {
    func create(for word: String) -> AnyPublisher<DictionaryDataState, Never>
}

struct DictionaryUseCase: DictionaryUseCaseType {
    
    init(dictionaryRepository: DictionaryRepositoryType) {
        self.dictionaryRepository = dictionaryRepository
    }
    
    func create(for word: String) -> AnyPublisher<DictionaryDataState, Never> {
        Future<DictionaryDataState, Never> { promise in
            Task {
                do {
                    let meaning = try await dictionaryRepository.meaning(for: word)
                    promise(.success(.data(meaning)))
                } catch {
                    promise(.success(.error))
                }
            }
        }
        .prepend(.loading)
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private
    private let dictionaryRepository: DictionaryRepositoryType
}

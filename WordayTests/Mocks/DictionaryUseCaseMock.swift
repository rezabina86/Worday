import Combine
@testable import Worday

final class DictionaryUseCaseMock: DictionaryUseCaseType {
    
    enum Call: Equatable {
        case create(word: String)
    }
    
    func create(for word: String) -> AnyPublisher<DictionaryDataState, Never> {
        calls.append(.create(word: word))
        return createSubject.eraseToAnyPublisher()
    }
    
    var calls: [Call] = []
    var createSubject: PassthroughSubject<DictionaryDataState, Never> = .init()
}

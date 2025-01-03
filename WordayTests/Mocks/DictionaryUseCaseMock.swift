import Combine
@testable import Worday

final class DictionaryUseCaseMock: DictionaryUseCaseType {
    
    enum Call: Equatable {
        case create(word: String)
    }
    
    func create(for word: String) -> AnyPublisher<DictionaryDataState, Never> {
        calls.append(.create(word: word))
        
        // Send the value set by the test on each call
        createSubject.send(createReturnValue)
        
        // Return the subject as a publisher
        return createSubject.eraseToAnyPublisher()
    }
    
    var calls: [Call] = []
    private var createSubject: CurrentValueSubject<DictionaryDataState, Never> = .init(.loading)
    var createReturnValue: DictionaryDataState = .loading
}

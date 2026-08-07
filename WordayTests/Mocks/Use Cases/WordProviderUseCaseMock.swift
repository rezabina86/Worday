@testable import Worday
import Foundation

final class WordProviderUseCaseMock: WordProviderUseCaseType {
    enum Call: Equatable {
        case fetch
        case store(word: String)
    }
    
    func fetch() -> FetchWordModel {
        calls.append(.fetch)
        return fetchReturnValue
    }
    
    func store(word: String) {
        calls.append(.store(word: word))
    }
    
    var calls: [Call] = []
    var fetchReturnValue: FetchWordModel = .error
}

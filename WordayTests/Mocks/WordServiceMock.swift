@testable import Worday

final class WordServiceMock: WordServiceType {
    
    enum Call: Equatable {
        case load
    }
    
    func load() throws -> WordEntity {
        calls.append(.load)
        return loadReturnValue
    }
    
    var calls: [Call] = []
    var loadReturnValue: WordEntity = .fake()
}

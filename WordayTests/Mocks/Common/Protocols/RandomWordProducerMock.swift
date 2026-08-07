import Foundation
@testable import Worday

final class RandomWordProducerMock: RandomWordProducerType {
    
    enum Call: Equatable {
        case randomElement(words: Set<String>)
    }
    
    func randomElement(in words: Set<String>) -> String? {
        calls.append(.randomElement(words: words))
        return randomElementReturnValue
    }
    
    var calls: [Call] = []
    var randomElementReturnValue: String?
}

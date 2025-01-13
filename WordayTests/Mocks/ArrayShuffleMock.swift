import Foundation
@testable import Worday

final class ArrayShuffleMock: ArrayShuffleType {
    
    enum Call: Equatable {
        case shuffle(array: [String])
    }
    
    func shuffle(array: [String]) -> [String] {
        calls.append(.shuffle(array: array))
        return shuffleReturnValue
    }
    
    var calls: [Call] = []
    var shuffleReturnValue: [String] = []
}

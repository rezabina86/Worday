@testable import Worday
import Foundation

final class WordRepositoryMock: WordRepositoryType {
    
    enum Call: Equatable {
        case words
    }
    
    func words() throws -> WordModel {
        calls.append(.words)
        return wordsReturnValue
    }
    
    var calls: [Call] = []
    var wordsReturnValue: WordModel = .fake()
}

import Foundation
@testable import Worday

final class WordMeaningViewModelFactoryMock: WordMeaningViewModelFactoryType {
    enum Call: Equatable {
        case create(word: String)
    }
    
    func create(word: String) -> WordMeaningViewModelType {
        calls.append(.create(word: word))
        return createReturnValue
    }
 
    var calls: [Call] = []
    var createReturnValue: WordMeaningViewModelType = WordMeaningViewModelMock()
}

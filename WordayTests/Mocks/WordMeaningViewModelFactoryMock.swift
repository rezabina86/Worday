import Foundation
@testable import Worday

final class WordMeaningViewModelFactoryMock: WordMeaningViewModelFactoryType {

    enum Call: Equatable {
        case make(word: String)
    }

    func make(word: String) -> WordMeaningViewModelType {
        calls.append(.make(word: word))
        return makeReturnValue
    }

    private(set) var calls: [Call] = []
    var makeReturnValue: WordMeaningViewModelType = WordMeaningViewModelMock()
}

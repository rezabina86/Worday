import Foundation
@testable import Worday

final class WordListViewStateConverterMock: WordListViewStateConverterType {
    enum Call: Equatable {
        case create
    }
    
    func create() -> WordListViewState {
        calls.append(.create)
        return createReturnValue
    }
    
    var calls: [Call] = []
    var createReturnValue: WordListViewState = .init(navigationTitle: "", cards: [])
}

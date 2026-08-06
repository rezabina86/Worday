import Foundation
@testable import Worday

final class WordListViewStateConverterMock: WordListViewStateConverterType {

    enum Call: Equatable {
        case make
    }

    func make() -> WordListViewState {
        calls.append(.make)
        return makeReturnValue
    }

    private(set) var calls: [Call] = []
    var makeReturnValue: WordListViewState = .init(navigationTitle: "", cards: [])
}

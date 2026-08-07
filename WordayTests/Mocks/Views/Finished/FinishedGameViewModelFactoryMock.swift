import Foundation
@testable import Worday

final class FinishedGameViewModelFactoryMock: FinishedGameViewModelFactoryType {

    enum Call: Equatable {
        case make(word: String)
    }

    func make(for word: String) -> FinishedGameViewModelType {
        calls.append(.make(word: word))
        return makeReturnValue
    }

    private(set) var calls: [Call] = []
    var makeReturnValue: FinishedGameViewModelType = FinishedGameViewModelMock()
}

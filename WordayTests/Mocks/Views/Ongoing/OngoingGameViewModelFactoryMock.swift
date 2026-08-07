import Foundation
@testable import Worday

final class OngoingGameViewModelFactoryMock: OngoingGameViewModelFactoryType {

    enum Call: Equatable {
        case make(word: String)
    }

    func make(with word: String) -> OngoingGameViewModelType {
        calls.append(.make(word: word))
        return makeReturnValue
    }

    private(set) var calls: [Call] = []
    var makeReturnValue: OngoingGameViewModelType = OngoingGameViewModelMock()
}

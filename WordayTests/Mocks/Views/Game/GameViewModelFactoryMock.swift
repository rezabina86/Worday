import Foundation
@testable import Worday

final class GameViewModelFactoryMock: GameViewModelFactoryType {

    enum Call: Equatable {
        case make
    }

    func make() -> GameViewModelType {
        calls.append(.make)
        return makeReturnValue
    }

    private(set) var calls: [Call] = []
    var makeReturnValue: GameViewModelType = GameViewModelMock()
}

import Foundation
@testable import Worday

final class GameViewModelFactoryMock: GameViewModelFactoryType {
    
    enum Call: Equatable {
        case create
    }
    
    func create() -> GameViewModelType {
        calls.append(.create)
        return createReturnValue
    }
    
    var calls: [Call] = []
    var createReturnValue: GameViewModelType = GameViewModelMock()
}

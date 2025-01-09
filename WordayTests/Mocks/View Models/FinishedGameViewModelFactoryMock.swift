import Foundation
@testable import Worday

final class FinishedGameViewModelFactoryMock: FinishedGameViewModelFactoryType {
    
    enum Call: Equatable {
        case create(word: String)
    }
    
    func create(for word: String) -> FinishedGameViewModelType {
        calls.append(.create(word: word))
        return createReturnValue
    }
    
    var calls: [Call] = []
    var createReturnValue: FinishedGameViewModelType = FinishedGameViewModelMock()
}

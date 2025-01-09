import Foundation
@testable import Worday

final class OngoingGameViewModelFactoryMock: OngoingGameViewModelFactoryType {
    
    enum Call: Equatable {
        case create(word: String)
    }
    
    func create(with word: String) -> OngoingGameViewModelType {
        calls.append(.create(word: word))
        return createReturnValue
    }
    
    var calls: [Call] = []
    var createReturnValue: OngoingGameViewModelType = OngoingGameViewModelMock()
}

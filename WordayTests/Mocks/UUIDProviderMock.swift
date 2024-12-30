import Foundation
@testable import Worday

final class UUIDProviderMock: UUIDProviderType {
    
    enum Call: Equatable {
        case create
    }
    
    func create() -> String {
        calls.append(.create)
        return createReturnValue
    }
    
    var calls: [Call] = []
    var createReturnValue: String = ""
}

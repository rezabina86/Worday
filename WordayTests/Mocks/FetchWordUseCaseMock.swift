@testable import Worday
import Foundation

final class FetchWordUseCaseMock: FetchWordUseCaseType {
    enum Call: Equatable {
        case fetch
    }
    
    func fetch() -> FetchWordModel {
        calls.append(.fetch)
        return fetchReturnValue
    }
    
    var calls: [Call] = []
    var fetchReturnValue: FetchWordModel = .error
}

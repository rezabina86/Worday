@testable import Worday
import Foundation

final class FetchWordUseCaseMock: FetchWordUseCaseType {
    
    enum Call: Equatable {
        case fetch
    }
    
    func fetch() throws -> String {
        calls.append(.fetch)
        if let error = fetchThrows { throw error }
        return fetchReturnValue
    }
    
    var calls: [Call] = []
    var fetchReturnValue: String = ""
    var fetchThrows: FetchWordUseCaseError?
}

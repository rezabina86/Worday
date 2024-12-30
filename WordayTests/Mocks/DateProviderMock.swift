import Foundation
@testable import Worday

final class DateProviderMock: DateProviderType {
    
    enum Call: Equatable {
        case now
    }
    
    func now() -> Date {
        calls.append(.now)
        return nowReturnValue
    }
    
    var calls: [Call] = []
    var nowReturnValue: Date = .now
}

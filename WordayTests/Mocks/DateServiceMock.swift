import Foundation
@testable import Worday

final class DateServiceMock: DateServiceType {
    
    enum Call: Equatable {
        case isDateInToday(Date?)
    }
    
    func isDateInToday(_ date: Date?) -> Bool {
        calls.append(.isDateInToday(date))
        return isDateInTodayReturnValue
    }
    
    var calls: [Call] = []
    var isDateInTodayReturnValue: Bool = false
}

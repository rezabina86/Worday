import Foundation
@testable import Worday

final class CalendarServiceMock: CalendarServiceType {
    
    enum Call: Equatable {
        case isDateInToday(date: Date)
        case daysBetween(from: Date, to: Date)
    }
    
    struct DateRange: Hashable {
        let from: Date
        let to: Date
    }
    
    func isDateInToday(_ date: Date) -> Bool {
        calls.append(.isDateInToday(date: date))
        return isDateInTodayReturnValues[date] ?? false
    }
    
    func daysBetween(from start: Date, to end: Date) -> Int? {
        calls.append(.daysBetween(from: start, to: end))
        let key = DateRange(from: start, to: end)
        return daysBetweenReturnValues[key] ?? nil
    }
    
    var calls: [Call] = []
    var isDateInTodayReturnValues: [Date: Bool] = [:]
    var daysBetweenReturnValues: [DateRange: Int?] = [:]
}

import Foundation

protocol DateServiceType {
    func isDateInToday(_ date: Date?) -> Bool
}

struct DateService: DateServiceType {
    func isDateInToday(_ date: Date?) -> Bool {
        guard let date else { return false }
        return Calendar.current.isDateInToday(date)
    }
}

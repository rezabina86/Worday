import Foundation

extension Date {
    static func fake(hour: Int, minute: Int, day: Int, month: Int, year: Int) -> Date? {
        let calendar = Calendar.current
        
        // Create a DateComponents instance with the provided values
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        
        // Attempt to create a Date object from the components
        return calendar.date(from: components)
    }
}

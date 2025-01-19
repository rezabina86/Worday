import Foundation

protocol CalendarServiceType {
    func isDateInToday(_ date: Date) -> Bool
    func daysBetween(from start: Date, to end: Date) -> Int?
}

extension Calendar: CalendarServiceType {
    
    func daysBetween(from start: Date, to end: Date) -> Int? {
        guard let startAdjusted = self.date(bySettingHour: 9, minute: 41, second: 0, of: start),
              let endAdjusted = self.date(bySettingHour: 9, minute: 41, second: 0, of: end) else { return nil }
        
        return self.dateComponents([.day], from: startAdjusted, to: endAdjusted).day
    }
    
}

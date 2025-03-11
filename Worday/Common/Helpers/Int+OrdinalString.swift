import Foundation

extension Int {
    var ordinalString: String {
        let suffixes = ["th", "st", "nd", "rd"]
        let mod100 = self % 100
        let mod10 = self % 10
        
        if (11...13).contains(mod100) {
            return "\(self)th"
        }
        
        let suffix = (1...3).contains(mod10) ? suffixes[mod10] : suffixes[0]
        return "\(self)\(suffix)"
    }
}

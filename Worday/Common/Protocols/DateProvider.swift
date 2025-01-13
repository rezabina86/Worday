import Foundation

protocol DateProviderType {
    func now() -> Date
}

extension Date: DateProviderType {
    func now() -> Date {
        .now
    }
}

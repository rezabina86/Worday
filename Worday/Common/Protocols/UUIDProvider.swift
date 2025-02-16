import Foundation

protocol UUIDProviderType {
    func create() -> String
}

struct UUIDProvider: UUIDProviderType {
    func create() -> String {
        UUID().uuidString
    }
}

import Foundation

protocol UUIDProviderType {
    func create() -> String
}

extension UUID: UUIDProviderType {
    func create() -> String {
        self.uuidString
    }
}

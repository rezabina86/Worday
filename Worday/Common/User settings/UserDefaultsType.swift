import Foundation

public protocol UserDefaultsType: AnyObject {
    func data(forKey key: String) -> Data?
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey key: String)
    func removeObject(forKey defaultName: String)
    func dictionaryRepresentation() -> [String: Any]
    @discardableResult
    func synchronize() -> Bool
}

extension UserDefaults: UserDefaultsType {}

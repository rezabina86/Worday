import Foundation
@testable import Worday

public final class UserDefaultsMock: UserDefaultsType {

    public enum Call: Equatable {
        case object(forKey: String)
        case data(forKey: String)
        case set(AnyHashable?, forKey: String)
        case removeObject(forKey: String)
        case dictionaryRepresentation
        case synchronize
    }

    public var calls: [Call] = []

    public var dictionary: [String: Any] = [:]

    public var setForKeyCalls = [(value: Any?, forKey: String)]()

    public func object(forKey defaultName: String) -> Any? {
        calls.append(.object(forKey: defaultName))
        return dictionary[defaultName]
    }

    public func data(forKey key: String) -> Data? {
        calls.append(.data(forKey: key))
        return dictionary[key] as? Data
    }

    public func set(_ value: Any?, forKey key: String) {
        dictionary[key] = value
        calls.append(.set(value as? AnyHashable, forKey: key))
        setForKeyCalls.append((value, key))
    }

    public func removeObject(forKey defaultName: String) {
        calls.append(.removeObject(forKey: defaultName))
        dictionary[defaultName] = nil
    }

    public func dictionaryRepresentation() -> [String: Any] {
        calls.append(.dictionaryRepresentation)
        return dictionary
    }

    public func synchronize() -> Bool {
        calls.append(.synchronize)
        return true
    }
}

import Foundation

protocol UserSettingsType: AnyObject {
    var currentWord: String? { get set }
    var numberOfTries: Int? { get set }
    func reset()
}

final class UserSettings: UserSettingsType {
    
    init(userDefaults: UserDefaultsType) {
        self.userDefaults = userDefaults
    }
    
    var currentWord: String? {
        get {
            return userDefaults.object(forKey: .currentWord) as? String
        }
        set {
            userDefaults.set(newValue, forKey: .currentWord)
        }
    }
    
    var numberOfTries: Int? {
        get {
            return userDefaults.object(forKey: .numberOfTries) as? Int
        }
        set {
            userDefaults.set(newValue, forKey: .numberOfTries)
        }
    }
    
    func reset() {
        let keysToRemove: [UserSettings.Key] = UserSettings.Key.allCases
        
        keysToRemove.forEach { userDefaults.set(nil, forKey: $0) }
    }
    
    // MARK: - Privates
    private let userDefaults: UserDefaultsType
    
    enum Key: String, CaseIterable {
        case currentWord = "current_word"
        case numberOfTries = "number_of_tries"
    }
}

private extension UserDefaultsType {
    func data(forKey key: UserSettings.Key) -> Data? {
        data(forKey: key.rawValue)
    }
    
    func set(_ value: Any?, forKey key: UserSettings.Key) {
        set(value, forKey: key.rawValue)
    }
    
    func object(forKey defaultName: UserSettings.Key) -> Any? {
        object(forKey: defaultName.rawValue)
    }
}

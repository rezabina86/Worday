import Foundation
@testable import Worday

final class UserSettingsMock: UserSettingsType {
    
    enum Call: Equatable {
        case reset
        case currentWord(CurrentWordCall)
    }
    
    func reset() {
        calls.append(.reset)
    }
    
    var currentWord: String? {
        get {
            calls.append(.currentWord(.get))
            return currentWordReturnValue
        }
        set {
            calls.append(.currentWord(.set(newValue)))
        }
    }
 
    var calls: [Call] = []
    var currentWordReturnValue: String? = nil
}

extension UserSettingsMock {
    var getCurrentWordCall: [Call] {
        calls.filter {
            switch $0 {
            case let .currentWord(call):
                return call == .get
            default:
                return false
            }
        }
    }
    
    var setCurrentWordCall: [Call] {
        calls.filter {
            switch $0 {
            case let .currentWord(call):
                switch call {
                case .set:
                    return true
                case .get:
                    return false
                }
            default:
                return false
            }
        }
    }
}

extension UserSettingsMock.Call {
    enum CurrentWordCall: Equatable {
        case get
        case set(String?)
    }
}

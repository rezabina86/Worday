import SwiftUI
import Combine
import Foundation

protocol AttemptTrackerUseCaseType {
    var numberOfTries: AnyPublisher<Int, Never> { get }
    func advance()
    func cleanup()
    func feedbackMessage() -> String
}

final class AttemptTrackerUseCase: AttemptTrackerUseCaseType {
    
    init(userSettings: UserSettingsType) {
        self.userSettings = userSettings
        self.numberOfTriesSubject = .init(userSettings.numberOfTries ?? 0)
    }
    
    var numberOfTries: AnyPublisher<Int, Never> {
        numberOfTriesSubject.eraseToAnyPublisher()
    }
    
    func advance() {
        let numberOfTries = numberOfTriesSubject.value + 1
        userSettings.numberOfTries = numberOfTries
        numberOfTriesSubject.send(numberOfTries)
    }
    
    func cleanup() {
        userSettings.numberOfTries = nil
        numberOfTriesSubject.send(0)
    }
    
    func feedbackMessage() -> String {
        let numberOfTries = numberOfTriesSubject.value
        return feedbackMessage(for: numberOfTries)
    }
    
    // MARK: - Privates
    private let userSettings: UserSettingsType
    
    private let numberOfTriesSubject: CurrentValueSubject<Int, Never>
    
    private func feedbackMessage(for tries: Int) -> String {
        let messages = [
            "Genius 🤯",         // 1st try
            "Magnificent ✨",    // 2nd try
            "Impressive 👏",     // 3rd try
            "Splendid 🎉",       // 4th try
            "Great 👍",          // 5th try
            "Nice 😊",           // 6th try
            "Good effort 💪",    // 7th try
            "You got it! 🎯"     // 8th try
        ]
        
        return tries > 0 && tries <= messages.count ? messages[tries - 1] : "Not bad 🤔"
    }
}

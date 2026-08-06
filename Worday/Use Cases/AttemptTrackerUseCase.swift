import Foundation
import Observation

protocol AttemptTrackerUseCaseType: AnyObject {
    var numberOfTries: Int { get }
    func advance()
    func cleanup()
    func feedbackMessage() -> String
    func ordinalString() -> String
}

@Observable
final class AttemptTrackerUseCase: AttemptTrackerUseCaseType {

    // MARK: - Life Cycle

    init(userSettings: UserSettingsType) {
        self.userSettings = userSettings
        self.numberOfTries = userSettings.numberOfTries ?? 0
    }

    // MARK: - Publics

    private(set) var numberOfTries: Int

    func advance() {
        numberOfTries += 1
        userSettings.numberOfTries = numberOfTries
    }

    func cleanup() {
        numberOfTries = 0
        userSettings.numberOfTries = nil
    }

    func feedbackMessage() -> String {
        feedbackMessage(for: numberOfTries)
    }

    func ordinalString() -> String {
        numberOfTries.ordinalString
    }

    // MARK: - Privates

    @ObservationIgnored private let userSettings: UserSettingsType

    private func feedbackMessage(for tries: Int) -> String {
        let messages = [
            "Genius",         // 1st try
            "Magnificent",    // 2nd try
            "Impressive",     // 3rd try
            "Splendid",       // 4th try
            "Great",          // 5th try
            "Nice",           // 6th try
            "Good effort",    // 7th try
            "You got it!"     // 8th try
        ]

        return tries > 0 && tries <= messages.count ? messages[tries - 1] : "Not bad"
    }
}

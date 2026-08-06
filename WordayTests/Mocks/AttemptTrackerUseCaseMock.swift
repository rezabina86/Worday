import Foundation
@testable import Worday

final class AttemptTrackerUseCaseMock: AttemptTrackerUseCaseType {

    enum Call: Equatable {
        case advance
        case cleanup
        case feedbackMessage
        case ordinalString
    }

    var numberOfTries: Int = 0

    func advance() {
        calls.append(.advance)
    }

    func cleanup() {
        calls.append(.cleanup)
    }

    func feedbackMessage() -> String {
        calls.append(.feedbackMessage)
        return feedbackMessageReturnValue
    }

    func ordinalString() -> String {
        calls.append(.ordinalString)
        return ordinalStringReturnValue
    }

    var feedbackMessageReturnValue: String = ""
    var ordinalStringReturnValue: String = ""
    private(set) var calls: [Call] = []
}

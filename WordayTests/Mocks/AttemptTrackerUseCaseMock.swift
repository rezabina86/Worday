import Foundation
import Combine
@testable import Worday

final class AttemptTrackerUseCaseMock: AttemptTrackerUseCaseType {
    
    enum Call: Equatable {
        case advance
        case cleanup
        case feedbackMessage
        case ordinalString
    }
    
    var numberOfTries: AnyPublisher<Int, Never> {
        numberOfTriesSubject.eraseToAnyPublisher()
    }
    
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
    var numberOfTriesSubject: CurrentValueSubject<Int, Never> = .init(0)
    var calls: [Call] = []
}

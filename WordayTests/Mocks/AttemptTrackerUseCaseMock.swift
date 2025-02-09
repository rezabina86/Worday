import Foundation
import Combine
@testable import Worday

final class AttemptTrackerUseCaseMock: AttemptTrackerUseCaseType {
    
    enum Call: Equatable {
        case advance
        case cleanup
        case feedbackMessage
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
    
    var feedbackMessageReturnValue: String = ""
    var numberOfTriesSubject: CurrentValueSubject<Int, Never> = .init(0)
    var calls: [Call] = []
}

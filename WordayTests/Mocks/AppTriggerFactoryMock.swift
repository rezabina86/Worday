import Combine
import Foundation
@testable import Worday

final class AppTriggerFactoryMock: AppTriggerFactoryType {
    enum Call: Equatable {
        case create(triggers: [AppTrigger])
    }
    
    func create(of triggers: [AppTrigger]) -> AnyPublisher<Void, Never> {
        calls.append(.create(triggers: triggers))
        return triggerRelay.eraseToAnyPublisher()
    }
    
    var calls: [Call] = []
    var triggerRelay: PassthroughSubject<Void, Never> = .init()
}

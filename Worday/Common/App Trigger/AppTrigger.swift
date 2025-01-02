import Combine
import Foundation

protocol AppTriggerFactoryType {
    func create(of triggers: [AppTrigger]) -> AnyPublisher<Void, Never>
}

enum AppTrigger: Equatable {
    case gameFinished
    case appBecameActive
}

struct AppTriggerFactory: AppTriggerFactoryType {
    
    let scenePhaseObserver: ScenePhaseObserverType
    let finishGameRelay: FinishGameRelayType
    
    func create(of triggers: [AppTrigger]) -> AnyPublisher<Void, Never> {
        let publishers = triggers.map { observable(for: $0) }
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }
    
    private func observable(for trigger: AppTrigger) -> AnyPublisher<Void, Never> {
        switch trigger {
        case .appBecameActive:
            return scenePhaseObserver.appBecameActive.prepend(()).eraseToAnyPublisher()
        case .gameFinished:
            return finishGameRelay.gameFinished.prepend(()).eraseToAnyPublisher()
        }
    }
    
}

private extension AnyPublisher {
    var asVoidPublisher: AnyPublisher<Void, Never> {
        self.map { _ in }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
}

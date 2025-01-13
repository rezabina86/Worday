import Combine
import Foundation

protocol AppTriggerFactoryType {
    func create(of triggers: [AppTrigger]) -> AnyPublisher<Void, Never>
}

enum AppTrigger: Equatable {
    case gameFinished
    case appBecameActive
    
    var needsInitialTrigger: Bool {
        switch self {
        case .gameFinished:
            return true
        case .appBecameActive:
            return false
        }
    }
}

struct AppTriggerFactory: AppTriggerFactoryType {
    
    let scenePhaseObserver: ScenePhaseObserverType
    let finishGameRelay: FinishGameRelayType
    
    func create(of triggers: [AppTrigger]) -> AnyPublisher<Void, Never> {
        let publishers = triggers.map { observable(for: $0) }
        if triggers.contains(where: { $0.needsInitialTrigger }) {
            return Publishers.MergeMany(publishers)
                .prepend(())
                .eraseToAnyPublisher()
        } else {
            return Publishers.MergeMany(publishers)
                .eraseToAnyPublisher()
        }
    }
    
    private func observable(for trigger: AppTrigger) -> AnyPublisher<Void, Never> {
        switch trigger {
        case .appBecameActive:
            return scenePhaseObserver.appBecameActive.eraseToAnyPublisher()
        case .gameFinished:
            return finishGameRelay.gameFinished.eraseToAnyPublisher()
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

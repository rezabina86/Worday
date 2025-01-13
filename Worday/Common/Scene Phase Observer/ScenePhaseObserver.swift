import Combine
import SwiftUI
import Foundation

protocol ScenePhaseObserverType {
    func phaseChanged(_ scenePhase: ScenePhase)
    
    var appBecameActive: AnyPublisher<Void, Never> { get }
}

final class ScenePhaseObserver: ScenePhaseObserverType {
    
    var appBecameActive: AnyPublisher<Void, Never> {
        _appBecameActive.eraseToAnyPublisher()
    }
    
    func phaseChanged(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .background:
            break
        case .inactive:
            break
        case .active:
            _appBecameActive.send(())
        @unknown default:
            break
        }
    }
    
    // MARK: - Privates
    private let _appBecameActive: PassthroughSubject<Void, Never> = .init()
}

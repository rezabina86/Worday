import Combine
import SwiftUI
import Foundation
@testable import Worday

final class ScenePhaseObserverMock: ScenePhaseObserverType {
    enum Call: Equatable {
        case phaseChanged(scenePhase: ScenePhase)
    }
    
    func phaseChanged(_ scenePhase: ScenePhase) {
        calls.append(.phaseChanged(scenePhase: scenePhase))
    }
    
    var appBecameActive: AnyPublisher<Void, Never> {
        appBecameActiveSubject.eraseToAnyPublisher()
    }
    
    var calls: [Call] = []
    var appBecameActiveSubject: PassthroughSubject<Void, Never> = .init()
}

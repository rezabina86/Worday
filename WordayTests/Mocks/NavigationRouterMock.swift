import SwiftUI
import Combine
@testable import Worday

final class NavigationRouterMock: NavigationRouterType {
    
    enum Call: Equatable {
        case setCurrentPath(path: NavigationPath)
        case gotoDestination(id: String)
    }
    
    var currentPath: AnyPublisher<NavigationPath, Never> {
        currentPathRelay.eraseToAnyPublisher()
    }
    
    func setCurrentPath(_ path: NavigationPath) {
        calls.append(.setCurrentPath(path: path))
    }
    
    func gotoDestination(_ destination: NavigationDestination) {
        calls.append(.gotoDestination(id: destination.id))
    }
    
    var currentPathRelay: PassthroughSubject<NavigationPath, Never> = .init()
    var calls: [Call] = []
}

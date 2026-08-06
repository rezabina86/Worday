import SwiftUI
@testable import Worday

final class NavigationRouterMock: NavigationRouterType {

    enum Call: Equatable {
        case setPath(path: NavigationPath)
        case gotoDestination(id: String)
    }

    var path: NavigationPath = .init() {
        didSet { calls.append(.setPath(path: path)) }
    }

    func gotoDestination(_ destination: NavigationDestination) {
        calls.append(.gotoDestination(id: destination.id))
    }

    private(set) var calls: [Call] = []
}

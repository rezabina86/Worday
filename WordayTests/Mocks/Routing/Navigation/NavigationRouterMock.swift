@testable import Worday

final class NavigationRouterMock: NavigationRouterType {

    enum Call: Equatable {
        case push(destination: NavigationDestination)
        case pop
        case popToRoot
        case setPath(path: [NavigationDestination])
    }

    private(set) var path: [NavigationDestination] = []

    func push(_ destination: NavigationDestination) {
        path.append(destination)
        calls.append(.push(destination: destination))
    }

    func pop() {
        calls.append(.pop)
    }

    func popToRoot() {
        calls.append(.popToRoot)
    }

    func setPath(_ path: [NavigationDestination]) {
        self.path = path
        calls.append(.setPath(path: path))
    }

    private(set) var calls: [Call] = []
}

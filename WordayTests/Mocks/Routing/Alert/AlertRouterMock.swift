@testable import Worday

final class AlertRouterMock: AlertRouterType {

    enum Call: Equatable {
        case present(alert: AlertState)
        case dismiss
    }

    private(set) var presented: AlertState?

    func present(_ alert: AlertState) {
        presented = alert
        calls.append(.present(alert: alert))
    }

    func dismiss() {
        presented = nil
        calls.append(.dismiss)
    }

    private(set) var calls: [Call] = []
}

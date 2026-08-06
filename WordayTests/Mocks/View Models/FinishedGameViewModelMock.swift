import Foundation
@testable import Worday

final class FinishedGameViewModelMock: FinishedGameViewModelType {

    enum Call: Equatable {
        case load
    }

    var viewState: FinishedGameViewState = .empty

    func load() async {
        calls.append(.load)
    }

    private(set) var calls: [Call] = []
}

@testable import Worday

final class GameViewModelMock: GameViewModelType {

    enum Call: Equatable {
        case refresh
        case observeGameFinished
    }

    var viewState: GameViewState = .empty

    func refresh() {
        calls.append(.refresh)
    }

    func observeGameFinished() async {
        calls.append(.observeGameFinished)
    }

    private(set) var calls: [Call] = []
}

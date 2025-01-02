import Combine
@testable import Worday

final class FinishGameRelay: FinishGameRelayType {
    
    enum Call: Equatable {
        case finishGame
    }
    
    func finishGame() {
        calls.append(.finishGame)
    }
    
    var gameFinished: AnyPublisher<Void, Never> {
        gameFinishedSubject.eraseToAnyPublisher()
    }
    
    var calls: [Call] = []
    var gameFinishedSubject: PassthroughSubject<Void,Never> = .init()
}

import Foundation
import Combine

protocol FinishGameRelayType {
    var gameFinished: AnyPublisher<Void, Never> { get }
    func finishGame()
}

final class FinishGameRelay: FinishGameRelayType {
    
    var gameFinished: AnyPublisher<Void, Never> {
        gameFinishedRelay.eraseToAnyPublisher()
    }
    
    func finishGame() {
        gameFinishedRelay.send(())
    }
    
    // MARK: - Privates
    private let gameFinishedRelay: PassthroughSubject<Void, Never> = .init()
}

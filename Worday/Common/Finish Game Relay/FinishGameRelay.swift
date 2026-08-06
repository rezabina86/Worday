import Foundation

protocol FinishGameRelayType: AnyObject {
    /// Emits once every time the current game is finished. A single long-lived consumer
    /// (the root game view) iterates it to re-fetch the day's state.
    var events: AsyncStream<Void> { get }
    func finishGame()
}

final class FinishGameRelay: FinishGameRelayType {

    // MARK: - Life Cycle

    init() {
        (events, continuation) = AsyncStream<Void>.makeStream()
    }

    // MARK: - Publics

    let events: AsyncStream<Void>

    func finishGame() {
        continuation.yield(())
    }

    // MARK: - Privates

    private let continuation: AsyncStream<Void>.Continuation
}

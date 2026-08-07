import Foundation
@testable import Worday

final class FinishGameRelayMock: FinishGameRelayType {

    // MARK: - Life Cycle

    init() {
        (events, continuation) = AsyncStream<Void>.makeStream()
    }

    // MARK: - Publics

    enum Call: Equatable {
        case finishGame
    }

    let events: AsyncStream<Void>

    func finishGame() {
        calls.append(.finishGame)
        continuation.yield(())
    }

    /// Terminates the event stream so a `for await` consumer's loop exits — lets tests
    /// deterministically drain buffered events then return.
    func finishStream() {
        continuation.finish()
    }

    private(set) var calls: [Call] = []

    // MARK: - Privates

    private let continuation: AsyncStream<Void>.Continuation
}

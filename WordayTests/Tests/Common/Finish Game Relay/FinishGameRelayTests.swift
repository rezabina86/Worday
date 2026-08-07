import Testing
@testable import Worday

struct FinishGameRelayTests {

    @Test("finishGame emits an event on the stream")
    func finishGameEmitsEvent() async {
        let sut = FinishGameRelay()

        sut.finishGame()

        var received = 0
        for await _ in sut.events {
            received += 1
            break
        }
        #expect(received == 1)
    }
}

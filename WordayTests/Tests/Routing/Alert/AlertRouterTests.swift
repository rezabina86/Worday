import Testing
@testable import Worday

struct AlertRouterTests {
    let sut = AlertRouter()

    @Test("it starts with nothing presented")
    func startsEmpty() {
        #expect(sut.presented == nil)
    }

    @Test("present sets the alert")
    func presentSetsAlert() {
        // `.fake` actions so the AlertState compares equal to itself (UserAction equality quirk).
        let alert = AlertState(title: "Oops", buttons: [.init(title: "OK", role: .cancel, onTap: .fake)])

        sut.present(alert)

        #expect(sut.presented == alert)
    }

    @Test("dismiss clears the alert")
    func dismissClears() {
        sut.present(AlertState(title: "Oops", buttons: [.init(title: "OK", onTap: .fake)]))

        sut.dismiss()

        #expect(sut.presented == nil)
    }
}

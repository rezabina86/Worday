import Testing
@testable import Worday

struct ModalRouterTests {
    let sut = ModalRouter()

    @Test("it starts with nothing presented")
    func startsEmpty() {
        #expect(sut.presented == nil)
    }

    @Test("present sets the destination")
    func presentSetsDestination() {
        sut.present(.info)

        #expect(sut.presented == .info)
    }

    @Test("dismiss clears the destination")
    func dismissClears() {
        sut.present(.info)

        sut.dismiss()

        #expect(sut.presented == nil)
    }
}

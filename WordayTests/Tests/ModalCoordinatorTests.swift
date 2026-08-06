import Testing
@testable import Worday

struct ModalCoordinatorTests {
    let sut = ModalCoordinator()

    @Test("it starts with no destination")
    func startsEmpty() {
        #expect(sut.destination == nil)
    }

    @Test("present sets the destination")
    func presentSetsDestination() {
        let destination = ModalCoordinatorDestination.info(.init(topics: [], versionString: ""))

        sut.present(destination)

        #expect(sut.destination == destination)
    }

    @Test("present nil clears the destination")
    func presentNilClears() {
        sut.present(.info(.init(topics: [], versionString: "")))
        sut.present(nil)

        #expect(sut.destination == nil)
    }
}

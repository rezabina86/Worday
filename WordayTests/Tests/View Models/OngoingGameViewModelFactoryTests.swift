import Testing
import Foundation
@testable import Worday

struct OngoingGameViewModelFactoryTests {
    var sut: OngoingGameViewModelFactory!
    var mockWordProviderUseCase: WordProviderUseCaseMock
    var mockArrayShuffle: ArrayShuffleMock
    var mockModalCoordinator: ModalCoordinatorMock
    
    init() {
        mockWordProviderUseCase = .init()
        mockArrayShuffle = .init()
        mockModalCoordinator = .init()
        sut = .init(wordProviderUseCase: mockWordProviderUseCase,
                    arrayShuffle: mockArrayShuffle,
                    modalCoordinator: mockModalCoordinator)
    }

    @Test func testCreate() async throws {
        let result = sut.create(with: "Test")
        #expect(result is OngoingGameViewModel)
    }
}

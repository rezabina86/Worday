import Testing
import Foundation
@testable import Worday

struct OngoingGameViewModelFactoryTests {
    var sut: OngoingGameViewModelFactory!
    var mockWordProviderUseCase: WordProviderUseCaseMock
    var mockArrayShuffle: ArrayShuffleMock
    var mockModalCoordinator: ModalCoordinatorMock
    var mockAttemptTrackerUseCase: AttemptTrackerUseCaseMock
    
    init() {
        mockWordProviderUseCase = .init()
        mockArrayShuffle = .init()
        mockModalCoordinator = .init()
        mockAttemptTrackerUseCase = .init()
        sut = .init(wordProviderUseCase: mockWordProviderUseCase,
                    arrayShuffle: mockArrayShuffle,
                    modalCoordinator: mockModalCoordinator,
                    attemptTrackerUseCase: mockAttemptTrackerUseCase)
    }

    @Test func testCreate() async throws {
        let result = sut.create(with: "Test")
        #expect(result is OngoingGameViewModel)
    }
}

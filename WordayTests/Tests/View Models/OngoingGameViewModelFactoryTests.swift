import Testing
import Foundation
@testable import Worday

struct OngoingGameViewModelFactoryTests {
    let sut: OngoingGameViewModelFactory!
    let mockWordProviderUseCase: WordProviderUseCaseMock
    let mockArrayShuffle: ArrayShuffleMock
    let mockModalCoordinator: ModalCoordinatorMock
    let mockAttemptTrackerUseCase: AttemptTrackerUseCaseMock
    let mockInfoModalViewStateConverter: InfoModalViewStateConverterMock
    
    init() {
        mockWordProviderUseCase = .init()
        mockArrayShuffle = .init()
        mockModalCoordinator = .init()
        mockAttemptTrackerUseCase = .init()
        mockInfoModalViewStateConverter = .init()
        sut = .init(wordProviderUseCase: mockWordProviderUseCase,
                    arrayShuffle: mockArrayShuffle,
                    modalCoordinator: mockModalCoordinator,
                    attemptTrackerUseCase: mockAttemptTrackerUseCase,
                    infoModalViewStateConverter: mockInfoModalViewStateConverter)
    }

    @Test func testCreate() async throws {
        let result = sut.create(with: "Test")
        #expect(result is OngoingGameViewModel)
    }
}

import Testing
import Foundation
@testable import Worday

struct OngoingGameViewModelFactoryTests {
    let sut: OngoingGameViewModelFactory!
    let mockWordProviderUseCase: WordProviderUseCaseMock
    let mockArrayShuffle: ArrayShuffleMock
    let mockModalRouter: ModalRouterMock
    let mockAttemptTrackerUseCase: AttemptTrackerUseCaseMock

    init() {
        mockWordProviderUseCase = .init()
        mockArrayShuffle = .init()
        mockModalRouter = .init()
        mockAttemptTrackerUseCase = .init()
        sut = .init(wordProviderUseCase: mockWordProviderUseCase,
                    arrayShuffle: mockArrayShuffle,
                    modalRouter: mockModalRouter,
                    attemptTrackerUseCase: mockAttemptTrackerUseCase)
    }

    @Test func makesViewModel() {
        let result = sut.make(with: "Test")
        #expect(result is OngoingGameViewModel)
    }
}

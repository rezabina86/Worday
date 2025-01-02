import Testing
import Foundation
@testable import Worday

struct OngoingGameViewModelFactoryTests {
    var sut: OngoingGameViewModelFactory!
    var mockWordProviderUseCase: WordProviderUseCaseMock
    var mockArrayShuffle: ArrayShuffleMock
    
    init() {
        mockWordProviderUseCase = .init()
        mockArrayShuffle = .init()
        sut = .init(wordProviderUseCase: mockWordProviderUseCase,
                    arrayShuffle: mockArrayShuffle)
    }

    @Test func testCreate() async throws {
        let result = sut.create(with: "Test")
        #expect(result is OngoingGameViewModel)
    }
}

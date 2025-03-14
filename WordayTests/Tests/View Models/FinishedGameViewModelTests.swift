import Combine
import Testing
import Foundation
@testable import Worday

final class FinishedGameViewModelTests {
    let sut: FinishedGameViewModel!
    let mockDictionaryUseCase: DictionaryUseCaseMock
    let mockStreakUseCase: StreakUseCaseMock
    let mockAttemptTrackerUseCase: AttemptTrackerUseCaseMock
    let mockWordListViewStateConverter: WordListViewStateConverterMock
    let mockNavigationRouter: NavigationRouterMock
    
    private let title: String = "Great job! 🎉"
    private let subtitle: String = "Come back tomorrow for another challenge!"
    
    private let testSubscriber: TestableSubscriber<FinishedGameViewState, Never>
    
    init() {
        mockDictionaryUseCase = .init()
        mockStreakUseCase = .init()
        mockAttemptTrackerUseCase = .init()
        mockWordListViewStateConverter = .init()
        mockNavigationRouter = .init()
        
        sut = .init(word: "abcde",
                    dictionaryUseCase: mockDictionaryUseCase,
                    streakUseCase: mockStreakUseCase,
                    attemptTrackerUseCase: mockAttemptTrackerUseCase,
                    wordListViewStateConverter: mockWordListViewStateConverter,
                    navigationRouter: mockNavigationRouter)
        
        testSubscriber = .init()
        sut.viewState
            .subscribe(testSubscriber)
    }
    
//    @Test func testPresentWordList() async throws {
//        testSubscriber.receivedValues.last?.allWordButton.onTap.action()
//        
//        #expect(mockWordListViewStateConverter.calls == [.create])
//    }
    
//    @Test func testLoadingState() async throws {
//        mockDictionaryUseCase.createSubject.send(.loading)
//        mockStreakUseCase.calculateStreakReturnValue = 1
//        mockStreakUseCase.totalPlayedReturnValue = 2
//        
//        
//        
//        #expect(testSubscriber.receivedValues == [
//            .empty,
//            .init(
//                title: title,
//                currentStreak: .init(title: "Current streak", value: 1),
//                totalPlayed: .init(title: "Played", value: 2),
//                meaning: .loading,
//                subtitle: subtitle
//            )
//        ])
//    }
}

private extension FinishedGameViewState {
    var isLoading: Bool {
        switch self.meaning {
        case .loading: return true
        case .meaning, .error: return false
        }
    }
    
    var isError: Bool {
        switch self.meaning {
        case .error: return true
        case .loading, .meaning: return false
        }
    }
    
    var isLoaded: Bool {
        switch self.meaning {
        case .meaning: return true
        case .error, .loading: return false
        }
    }
}

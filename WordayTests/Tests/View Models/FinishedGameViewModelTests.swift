import Combine
import Testing
import Foundation
@testable import Worday

struct FinishedGameViewModelTests {
    let sut: FinishedGameViewModel
    
    let mockDictionaryUseCase: DictionaryUseCaseMock
    let mockStreakUseCase: StreakUseCaseMock
    let mockAttemptTrackerUseCase: AttemptTrackerUseCaseMock
    let mockWordListViewStateConverter: WordListViewStateConverterMock
    let mockNavigationRouter: NavigationRouterMock
    let mockSchedulerFactory: SchedulerFactoryMock
    
    private let title: String = "Great job! 🎉"
    private let subtitle: String = "Come back tomorrow for another challenge!"
    
    private let testSubscriber: TestableSubscriber<FinishedGameViewState, Never>
    
    init() {
        mockDictionaryUseCase = .init()
        mockStreakUseCase = .init()
        mockAttemptTrackerUseCase = .init()
        mockWordListViewStateConverter = .init()
        mockNavigationRouter = .init()
        mockSchedulerFactory = .init()
        
        mockSchedulerFactory.makeMainSchedulerReturnValue = AnySchedulerType(SchedulerMock())
        mockAttemptTrackerUseCase.ordinalStringReturnValue = "1st"
        mockAttemptTrackerUseCase.feedbackMessageReturnValue = "Great job! 🎉"
        mockStreakUseCase.calculateStreakReturnValue = 1
        mockStreakUseCase.totalPlayedReturnValue = 2
        
        sut = .init(word: "abcde",
                    dictionaryUseCase: mockDictionaryUseCase,
                    streakUseCase: mockStreakUseCase,
                    attemptTrackerUseCase: mockAttemptTrackerUseCase,
                    wordListViewStateConverter: mockWordListViewStateConverter,
                    navigationRouter: mockNavigationRouter,
                    schedulerFactory: mockSchedulerFactory)
        
        testSubscriber = .init()
        sut.viewState
            .subscribe(testSubscriber)
    }
    
    @Test("it creates loading state and navigates to word list on tap the button")
    func testLoadingState() async throws {
        mockDictionaryUseCase.createSubject.send(.loading)
        
        #expect(testSubscriber.receivedValues == [
            .empty,
            .init(
                allWordButton: .init(title: "All words", onTap: .fake),
                title: title,
                scoreString: "You solved it on your 1st try",
                currentStreak: .init(title: "Current streak", value: 1),
                totalPlayed: .init(title: "Played", value: 2),
                meaning: .loading,
                subtitle: subtitle
            )
        ])
        
        testSubscriber.receivedValues.last?.allWordButton.onTap.action()
        
        #expect(mockWordListViewStateConverter.calls == [.create])
    }
    
    @Test("it creates error state")
    func testErrorState() async throws {
        mockDictionaryUseCase.createSubject.send(.error)
        
        #expect(testSubscriber.receivedValues == [
            .empty,
            .init(
                allWordButton: .init(title: "All words", onTap: .fake),
                title: title,
                scoreString: "You solved it on your 1st try",
                currentStreak: .init(title: "Current streak", value: 1),
                totalPlayed: .init(title: "Played", value: 2),
                meaning: .error(message: "You’ve solved today’s puzzle. The word was", word: "ABCDE"),
                subtitle: subtitle
            )
        ])
        
        testSubscriber.receivedValues.last?.allWordButton.onTap.action()
        
        #expect(mockWordListViewStateConverter.calls == [.create])
    }
    
    @Test("it creates loaded state")
    func testLoadedState() async throws {
        mockDictionaryUseCase.createSubject.send(.data(.fake()))
        
        #expect(testSubscriber.receivedValues == [
            .empty,
            .init(
                allWordButton: .init(title: "All words", onTap: .fake),
                title: title,
                scoreString: "You solved it on your 1st try",
                currentStreak: .init(title: "Current streak", value: 1),
                totalPlayed: .init(title: "Played", value: 2),
                meaning: .meaning(
                    viewState: .init(
                        word: "WORD",
                        meanings: [
                            .init(
                                id: "0",
                                type: "noun",
                                definitions: [
                                    .init(
                                        id: "0",
                                        index: 1,
                                        definition: "definition"
                                    )
                                ]
                            )
                        ],
                        selectedMeaning: nil,
                        onSelectMeaning: { _ in }
                    )
                ),
                subtitle: subtitle
            )
        ])
        
        testSubscriber.receivedValues.last?.allWordButton.onTap.action()
        
        #expect(mockWordListViewStateConverter.calls == [.create])
        
        if case let .meaning(viewState) = testSubscriber.receivedValues.last?.meaning {
            viewState.onSelectMeaning(viewState.meanings[0])
            #expect(testSubscriber.receivedValues == [
                .empty,
                .init(
                    allWordButton: .init(title: "All words", onTap: .fake),
                    title: title,
                    scoreString: "You solved it on your 1st try",
                    currentStreak: .init(title: "Current streak", value: 1),
                    totalPlayed: .init(title: "Played", value: 2),
                    meaning: .meaning(
                        viewState: .init(
                            word: "WORD",
                            meanings: [
                                .init(
                                    id: "0",
                                    type: "noun",
                                    definitions: [
                                        .init(
                                            id: "0",
                                            index: 1,
                                            definition: "definition"
                                        )
                                    ]
                                )
                            ],
                            selectedMeaning: nil,
                            onSelectMeaning: { _ in }
                        )
                    ),
                    subtitle: subtitle
                ),
                .init(
                    allWordButton: .init(title: "All words", onTap: .fake),
                    title: title,
                    scoreString: "You solved it on your 1st try",
                    currentStreak: .init(title: "Current streak", value: 1),
                    totalPlayed: .init(title: "Played", value: 2),
                    meaning: .meaning(
                        viewState: .init(
                            word: "WORD",
                            meanings: [
                                .init(
                                    id: "0",
                                    type: "noun",
                                    definitions: [
                                        .init(
                                            id: "0",
                                            index: 1,
                                            definition: "definition"
                                        )
                                    ]
                                )
                            ],
                            selectedMeaning: .init(
                                id: "0",
                                type: "noun",
                                definitions: [
                                    .init(
                                        id: "0",
                                        index: 1,
                                        definition: "definition"
                                    )
                                ]
                            ),
                            onSelectMeaning: { _ in }
                        )
                    ),
                    subtitle: subtitle
                )
            ])
        }
    }
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

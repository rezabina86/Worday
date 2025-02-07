import Combine
import Foundation

protocol FinishedGameViewModelFactoryType {
    func create(for word: String) -> FinishedGameViewModelType
}

struct FinishedGameViewModelFactory: FinishedGameViewModelFactoryType {
    let dictionaryUseCase: DictionaryUseCaseType
    let streakUseCase: StreakUseCaseType
    
    func create(for word: String) -> FinishedGameViewModelType {
        FinishedGameViewModel(word: word,
                              dictionaryUseCase: dictionaryUseCase,
                              streakUseCase: streakUseCase)
    }
}

protocol FinishedGameViewModelType {
    var viewState: AnyPublisher<FinishedGameViewState, Never> { get }
}

final class FinishedGameViewModel: FinishedGameViewModelType {
    
    init(
        word: String,
        dictionaryUseCase: DictionaryUseCaseType,
        streakUseCase: StreakUseCaseType
    ) {
        self.streakUseCase = streakUseCase
        
        dictionaryUseCase.create(for: word)
            .combineLatest(selectedMeaningSubject)
            .receive(on: RunLoop.main)
            .map { [weak self] dataState, selectedMeaning -> FinishedGameViewState in
                guard let self else { return .empty }
                switch dataState {
                case .error:
                    return .init(
                        title: title,
                        currentStreak: createCurrentStreak(),
                        totalPlayed: createTotalPlayed(),
                        meaning: .error(message: "You’ve solved today’s puzzle. The word was", word: word.uppercased()),
                        subtitle: subtitle
                    )
                case .loading:
                    return .init(
                        title: title,
                        currentStreak: createCurrentStreak(),
                        totalPlayed: createTotalPlayed(),
                        meaning: .loading,
                        subtitle: subtitle
                    )
                case let .data(model):
                    return createLoadedViewState(from: model,
                                                 selectedMeaning: selectedMeaning)
                }
            }
            .handleEvents(receiveOutput: { [weak self] viewState in
                self?.setSelectedMeaningIfNecessary(from: viewState)
            })
            .assign(to: \.value, on: viewStateSubject)
            .store(in: &cancellables)
    }
    
    var viewState: AnyPublisher<FinishedGameViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Privates
    private var cancellables: Set<AnyCancellable> = []
    private let viewStateSubject: CurrentValueSubject<FinishedGameViewState, Never> = .init(.empty)
    private let selectedMeaningSubject: CurrentValueSubject<FinishedGameViewState.Meaning.MeaningViewState.Meaning?, Never> = .init(nil)
    
    private let streakUseCase: StreakUseCaseType
    
    private let title: String = "Great job! 🎉"
    private let subtitle: String = "Come back tomorrow for another challenge!"
    
    private lazy var currentStreak: Int = {
        streakUseCase.calculateStreak()
    }()
    
    private lazy var totalPlayed: Int = {
        streakUseCase.totalPlayed()
    }()
    
    private func createCurrentStreak() -> FinishedGameViewState.Streak {
        .init(title: "Current streak", value: currentStreak)
    }
    
    private func createTotalPlayed() -> FinishedGameViewState.Streak {
        .init(title: "Played", value: totalPlayed)
    }
    
    private func createLoadedViewState(from model: WordMeaningModel,
                                       selectedMeaning: FinishedGameViewState.Meaning.MeaningViewState.Meaning?) -> FinishedGameViewState {
        let meanings: [FinishedGameViewState.Meaning.MeaningViewState.Meaning] = model.meanings
            .enumerated()
            .map { .init(
                from: $0.element,
                index: $0.offset
            )}

        return .init(
            title: title,
            currentStreak: createCurrentStreak(),
            totalPlayed: createTotalPlayed(),
            meaning: .meaning(viewState: .init(
                word: model.word.uppercased(),
                meanings: meanings,
                selectedMeaning: selectedMeaning,
                onSelectMeaning: { [selectedMeaningSubject] meaning in
                    selectedMeaningSubject.send(meaning)
                }
            )),
            subtitle: subtitle
        )
    }
    
    private func setSelectedMeaningIfNecessary(from viewState: FinishedGameViewState) {
        guard selectedMeaningSubject.value == nil else { return }
        switch viewState.meaning {
        case .loading, .error: return
        case let .meaning(viewState):
            self.selectedMeaningSubject.send(viewState.meanings.first)
        }
    }
}

private extension FinishedGameViewState.Meaning.MeaningViewState.Meaning {
    init(from model: WordMeaningModel.Meaning, index: Int) {
        self = .init(
            id: "\(index)",
            type: model.partOfSpeech.rawValue,
            definitions: model.definitions.enumerated().map {
                .init(
                    id: "\($0.offset)",
                    index: $0.offset + 1,
                    definition: $0.element.definition
                )
            }
        )
    }
}

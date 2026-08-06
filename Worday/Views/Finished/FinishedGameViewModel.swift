import Foundation
import Observation

protocol FinishedGameViewModelFactoryType {
    func make(for word: String) -> FinishedGameViewModelType
}

struct FinishedGameViewModelFactory: FinishedGameViewModelFactoryType {
    let dictionaryUseCase: DictionaryUseCaseType
    let streakUseCase: StreakUseCaseType
    let attemptTrackerUseCase: AttemptTrackerUseCaseType
    let wordListViewStateConverter: WordListViewStateConverterType
    let navigationRouter: NavigationRouterType

    func make(for word: String) -> FinishedGameViewModelType {
        FinishedGameViewModel(word: word,
                              dictionaryUseCase: dictionaryUseCase,
                              streakUseCase: streakUseCase,
                              attemptTrackerUseCase: attemptTrackerUseCase,
                              wordListViewStateConverter: wordListViewStateConverter,
                              navigationRouter: navigationRouter)
    }
}

protocol FinishedGameViewModelType: AnyObject {
    var viewState: FinishedGameViewState { get }
    func load() async
}

@Observable
final class FinishedGameViewModel: FinishedGameViewModelType {

    // MARK: - Life Cycle

    init(
        word: String,
        dictionaryUseCase: DictionaryUseCaseType,
        streakUseCase: StreakUseCaseType,
        attemptTrackerUseCase: AttemptTrackerUseCaseType,
        wordListViewStateConverter: WordListViewStateConverterType,
        navigationRouter: NavigationRouterType
    ) {
        self.word = word
        self.dictionaryUseCase = dictionaryUseCase
        self.wordListViewStateConverter = wordListViewStateConverter
        self.navigationRouter = navigationRouter
        self.title = attemptTrackerUseCase.feedbackMessage()
        self.scoreMessage = "You solved it on your \(attemptTrackerUseCase.ordinalString()) try"
        self.currentStreakValue = streakUseCase.calculateStreak()
        self.totalPlayedValue = streakUseCase.totalPlayed()
    }

    // MARK: - Publics

    var viewState: FinishedGameViewState {
        switch dataState {
        case .error:
            return makeViewState(
                meaning: .error(message: "You’ve solved today’s puzzle. The word was", word: word.uppercased())
            )
        case .loading:
            return makeViewState(meaning: .loading)
        case let .data(model):
            return makeViewState(meaning: makeMeaningSection(from: model))
        }
    }

    func load() async {
        dataState = await dictionaryUseCase.meaning(for: word)
        selectDefaultMeaningIfNeeded()
    }

    // MARK: - Privates

    @ObservationIgnored private let word: String
    @ObservationIgnored private let dictionaryUseCase: DictionaryUseCaseType
    @ObservationIgnored private let wordListViewStateConverter: WordListViewStateConverterType
    @ObservationIgnored private let navigationRouter: NavigationRouterType

    @ObservationIgnored private let title: String
    @ObservationIgnored private let scoreMessage: String
    @ObservationIgnored private let subtitle: String = "Come back tomorrow for another challenge!"
    @ObservationIgnored private let currentStreakValue: Int
    @ObservationIgnored private let totalPlayedValue: Int

    private var dataState: DictionaryDataState = .loading
    private var selectedMeaning: FinishedGameViewState.Meaning.MeaningViewState.Meaning?

    private func makeViewState(meaning: FinishedGameViewState.Meaning) -> FinishedGameViewState {
        .init(
            allWordButton: allWordsButtonState,
            title: title,
            scoreString: scoreMessage,
            currentStreak: .init(title: "Current streak", value: currentStreakValue),
            totalPlayed: .init(title: "Played", value: totalPlayedValue),
            meaning: meaning,
            subtitle: subtitle
        )
    }

    private func makeMeaningSection(from model: WordMeaningModel) -> FinishedGameViewState.Meaning {
        .meaning(viewState: .init(
            word: model.word.uppercased(),
            meanings: meanings(from: model),
            selectedMeaning: selectedMeaning,
            onSelectMeaning: { [weak self] meaning in self?.selectedMeaning = meaning }
        ))
    }

    private func meanings(from model: WordMeaningModel) -> [FinishedGameViewState.Meaning.MeaningViewState.Meaning] {
        model.meanings
            .enumerated()
            .map { .init(from: $0.element, index: $0.offset) }
    }

    private func selectDefaultMeaningIfNeeded() {
        guard selectedMeaning == nil, case let .data(model) = dataState else { return }
        selectedMeaning = meanings(from: model).first
    }

    private var allWordsButtonState: FinishedGameViewState.AllWordButton {
        .init(
            title: "All words",
            onTap: .init { [wordListViewStateConverter, navigationRouter] in
                navigationRouter
                    .gotoDestination(.wordList(viewState: wordListViewStateConverter.make()))
            }
        )
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

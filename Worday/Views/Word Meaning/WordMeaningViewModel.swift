import Foundation
import Observation

protocol WordMeaningViewModelFactoryType {
    func make(word: String) -> WordMeaningViewModelType
}

struct WordMeaningViewModelFactory: WordMeaningViewModelFactoryType {
    let dictionaryUseCase: DictionaryUseCaseType
    let alertRouter: AlertRouterType

    func make(word: String) -> WordMeaningViewModelType {
        WordMeaningViewModel(word: word, dictionaryUseCase: dictionaryUseCase, alertRouter: alertRouter)
    }
}

protocol WordMeaningViewModelType: AnyObject {
    var viewState: WordMeaningViewState { get }
    func load() async
}

@Observable
final class WordMeaningViewModel: WordMeaningViewModelType {

    // MARK: - Life Cycle

    init(word: String, dictionaryUseCase: DictionaryUseCaseType, alertRouter: AlertRouterType) {
        self.word = word
        self.dictionaryUseCase = dictionaryUseCase
        self.alertRouter = alertRouter
    }

    // MARK: - Publics

    var viewState: WordMeaningViewState {
        switch dataState {
        case .error:
            return .error(message: "There was an error loading the word. The word is", word: word.uppercased())
        case .loading:
            return .loading
        case let .data(model):
            return makeMeaningViewState(from: model)
        }
    }

    func load() async {
        dataState = await dictionaryUseCase.meaning(for: word)
        selectDefaultMeaningIfNeeded()
        if case .error = dataState { presentRetryAlert() }
    }

    // MARK: - Privates

    @ObservationIgnored private let word: String
    @ObservationIgnored private let dictionaryUseCase: DictionaryUseCaseType
    @ObservationIgnored private let alertRouter: AlertRouterType

    private var dataState: DictionaryDataState = .loading
    private var selectedMeaning: WordMeaningViewState.MeaningViewState.Meaning?

    private func makeMeaningViewState(from model: WordMeaningModel) -> WordMeaningViewState {
        .meaning(viewState: .init(
            word: model.word.uppercased(),
            meanings: meanings(from: model),
            selectedMeaning: selectedMeaning,
            onSelectMeaning: { [weak self] meaning in self?.selectedMeaning = meaning }
        ))
    }

    private func meanings(from model: WordMeaningModel) -> [WordMeaningViewState.MeaningViewState.Meaning] {
        model.meanings
            .enumerated()
            .map { .init(from: $0.element, index: $0.offset) }
    }

    private func selectDefaultMeaningIfNeeded() {
        guard selectedMeaning == nil, case let .data(model) = dataState else { return }
        selectedMeaning = meanings(from: model).first
    }

    private func presentRetryAlert() {
        alertRouter.present(.meaningLoadFailure(onRetry: { [weak self] in self?.retry() }))
    }

    private func retry() {
        Task { await load() }
    }
}

private extension WordMeaningViewState.MeaningViewState.Meaning {
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

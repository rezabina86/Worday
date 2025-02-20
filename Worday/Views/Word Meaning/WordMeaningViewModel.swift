import Combine
import Foundation

protocol WordMeaningViewModelFactoryType {
    func create(word: String) -> WordMeaningViewModelType
}

struct WordMeaningViewModelFactory: WordMeaningViewModelFactoryType {
    let dictionaryUseCase: DictionaryUseCaseType
    
    func create(word: String) -> WordMeaningViewModelType {
        WordMeaningViewModel(word: word,
                             dictionaryUseCase: dictionaryUseCase)
    }
}

protocol WordMeaningViewModelType {
    var viewState: AnyPublisher<WordMeaningViewState, Never> { get }
}

final class WordMeaningViewModel: WordMeaningViewModelType {
    
    init(word: String,
         dictionaryUseCase: DictionaryUseCaseType) {
        
        dictionaryUseCase.create(for: word)
            .combineLatest(selectedMeaningSubject)
            .receive(on: RunLoop.main)
            .map { [weak self] dataState, selectedMeaning -> WordMeaningViewState in
                guard let self else { return .loading }
                switch dataState {
                case .error:
                    return .error(message: "There was an error loading the word. The word is", word: word.uppercased())
                case .loading:
                    return .loading
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
    
    var viewState: AnyPublisher<WordMeaningViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Privates
    private var cancellables: Set<AnyCancellable> = []
    private let viewStateSubject: CurrentValueSubject<WordMeaningViewState, Never> = .init(.loading)
    private let selectedMeaningSubject: CurrentValueSubject<WordMeaningViewState.MeaningViewState.Meaning?, Never> = .init(nil)
    
    private func createLoadedViewState(from model: WordMeaningModel,
                                       selectedMeaning: WordMeaningViewState.MeaningViewState.Meaning?) -> WordMeaningViewState {
        let meanings: [WordMeaningViewState.MeaningViewState.Meaning] = model.meanings
            .enumerated()
            .map { .init(
                from: $0.element,
                index: $0.offset
            )}

        return .meaning(viewState: .init(
            word: model.word.uppercased(),
            meanings: meanings,
            selectedMeaning: selectedMeaning,
            onSelectMeaning: { [selectedMeaningSubject] meaning in
                selectedMeaningSubject.send(meaning)
            }
        ))
    }
    
    private func setSelectedMeaningIfNecessary(from viewState: WordMeaningViewState) {
        guard selectedMeaningSubject.value == nil else { return }
        switch viewState {
        case .loading, .error: return
        case let .meaning(viewState):
            self.selectedMeaningSubject.send(viewState.meanings.first)
        }
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

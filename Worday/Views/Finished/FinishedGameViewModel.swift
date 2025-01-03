import Combine

protocol FinishedGameViewModelFactoryType {
    func create(for word: String) -> FinishedGameViewModelType
}

struct FinishedGameViewModelFactory: FinishedGameViewModelFactoryType {
    let dictionaryUseCase: DictionaryUseCaseType
    
    func create(for word: String) -> FinishedGameViewModelType {
        FinishedGameViewModel(word: word,
                              dictionaryUseCase: dictionaryUseCase)
    }
}

protocol FinishedGameViewModelType {
    var viewState: AnyPublisher<FinishedGameViewState, Never> { get }
}

final class FinishedGameViewModel: FinishedGameViewModelType {
    
    init(
        word: String,
        dictionaryUseCase: DictionaryUseCaseType
    ) {
        self.dictionaryUseCase = dictionaryUseCase
        
        dictionaryUseCase.create(for: word).map { [weak self] dataState -> FinishedGameViewState in
            guard let self else { return .empty }
            switch dataState {
            case .error:
                return .init(
                    title: title,
                    meaning: .error(message: "You’ve solved today’s puzzle. The word was \(word)"),
                    subtitle: subtitle
                )
            case .loading:
                return .init(
                    title: title,
                    meaning: .loading,
                    subtitle: subtitle
                )
            case let .data(model):
                return createLoadedViewState(from: model)
            }
        }
        .sink(receiveValue: { [weak self] in
            guard let self else { return }
            viewStateSubject.send($0)
        })
        .store(in: &cancellables)
    }
    
    var viewState: AnyPublisher<FinishedGameViewState, Never> {
        viewStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Privates
    private let dictionaryUseCase: DictionaryUseCaseType
    
    private var cancellables: Set<AnyCancellable> = []
    private let viewStateSubject: CurrentValueSubject<FinishedGameViewState, Never> = .init(.empty)
    
    private let title: String = "Great job!"
    private let subtitle: String = "Come back tomorrow for another challenge!"
    
    private func createLoadedViewState(from model: WordMeaningModel) -> FinishedGameViewState {
        .init(
            title: title,
            meaning: .meaning(viewState: .init(
                word: model.word,
                defination: model.meanings.map { .init(from: $0) }
            )),
            subtitle: subtitle
        )
    }
}

private extension FinishedGameViewState.Meaning.MeaningViewState.Definition {
    init(from model: WordMeaningModel.Meaning) {
        self = .init(
            id: .init(),
            type: "[\(model.partOfSpeech.rawValue)]",
            meaning: model.definitions.first?.definition ?? ""
        )
    }
}

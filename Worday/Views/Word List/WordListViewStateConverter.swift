import Foundation

protocol WordListViewStateConverterType {
    func create() -> WordListViewState
}

struct WordListViewStateConverter: WordListViewStateConverterType {
    
    init(wordContext: WordStorageModelContextType,
         wordMeaningViewModelFactory: WordMeaningViewModelFactoryType,
         navigationRouter: NavigationRouterType) {
        self.wordContext = wordContext
        self.wordMeaningViewModelFactory = wordMeaningViewModelFactory
        self.navigationRouter = navigationRouter
    }
    
    func create() -> WordListViewState {
        let allWords = (try? self.wordContext.fetchAll()) ?? []
        let cards: [WordListViewState.Card] = allWords.enumerated()
            .compactMap { index, word in
                .init(
                    id: "\(index)",
                    dateSection: .init(
                        title: "Played on",
                        date: word.playedAt
                    ),
                    word: word.word,
                    onTap: .init {
                        self.navigationRouter.gotoDestination(
                            .wordMeaning(viewModel: wordMeaningViewModelFactory.create(word: word.word))
                        )
                    }
                )
            }
        
        return .init(navigationTitle: "Words", cards: cards)
    }
    
    // MARK: - Privates
    private let wordContext: WordStorageModelContextType
    private let wordMeaningViewModelFactory: WordMeaningViewModelFactoryType
    private let navigationRouter: NavigationRouterType
}

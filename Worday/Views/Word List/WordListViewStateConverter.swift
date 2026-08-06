import Foundation

protocol WordListViewStateConverterType {
    func make() -> WordListViewState
}

struct WordListViewStateConverter: WordListViewStateConverterType {
    
    init(wordContext: WordStorageModelContextType,
         wordMeaningViewModelFactory: WordMeaningViewModelFactoryType,
         navigationRouter: NavigationRouterType) {
        self.wordContext = wordContext
        self.wordMeaningViewModelFactory = wordMeaningViewModelFactory
        self.navigationRouter = navigationRouter
    }
    
    func make() -> WordListViewState {
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
                    onTap: .init { [navigationRouter, wordMeaningViewModelFactory] in
                        navigationRouter.gotoDestination(
                            .wordMeaning(viewModel: wordMeaningViewModelFactory.make(word: word.word))
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

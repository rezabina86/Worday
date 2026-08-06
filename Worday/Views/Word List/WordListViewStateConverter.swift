import Foundation

protocol WordListViewStateConverterType {
    func make() -> WordListViewState
}

struct WordListViewStateConverter: WordListViewStateConverterType {
    
    init(wordContext: WordStorageModelContextType,
         navigationRouter: NavigationRouterType) {
        self.wordContext = wordContext
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
                    onTap: .init { [navigationRouter] in
                        navigationRouter.push(.wordMeaning(word: word.word))
                    }
                )
            }
        
        return .init(navigationTitle: "Words", cards: cards)
    }
    
    // MARK: - Privates
    private let wordContext: WordStorageModelContextType
    private let navigationRouter: NavigationRouterType
}

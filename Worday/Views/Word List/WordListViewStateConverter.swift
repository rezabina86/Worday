import Foundation

protocol WordListViewStateConverterType {
    func make() -> WordListViewState
}

struct WordListViewStateConverter: WordListViewStateConverterType {
    
    init(playedWordsLibrary: PlayedWordsLibraryType,
         navigationRouter: NavigationRouterType) {
        self.playedWordsLibrary = playedWordsLibrary
        self.navigationRouter = navigationRouter
    }
    
    func make() -> WordListViewState {
        let allWords = playedWordsLibrary.words
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
    private let playedWordsLibrary: PlayedWordsLibraryType
    private let navigationRouter: NavigationRouterType
}

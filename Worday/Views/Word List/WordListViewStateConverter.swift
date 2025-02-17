import Foundation

protocol WordListViewStateConverterType {
    func create() -> WordListViewState
}

struct WordListViewStateConverter: WordListViewStateConverterType {
    
    init(wordContext: WordStorageModelContextType) {
        self.wordContext = wordContext
    }
    
    func create() -> WordListViewState {
        let allWords = (try? self.wordContext.fetchAll()) ?? []
        let cards: [WordListViewState.Card] = allWords.enumerated()
            .compactMap { index, word in
                .init(
                    id: "\(index)",
                    dateSection: .init(
                        title: "Played on:",
                        date: word.playedAt
                    ),
                    word: word.word,
                    onTap: .empty
                )
            }
        
        return .init(navigationTitle: "Words", cards: cards)
    }
    
    // MARK: - Privates
    private let wordContext: WordStorageModelContextType
}

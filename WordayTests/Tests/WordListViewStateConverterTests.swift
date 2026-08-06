import Testing
import Foundation
@testable import Worday

struct WordListViewStateConverterTests {
    
    let sut: WordListViewStateConverter
    let mockPlayedWordsLibrary: PlayedWordsLibraryMock
    let mockNavigationRouter: NavigationRouterMock

    init() {
        mockPlayedWordsLibrary = .init()
        mockNavigationRouter = .init()
        sut = .init(playedWordsLibrary: mockPlayedWordsLibrary,
                    navigationRouter: mockNavigationRouter)
    }

    @Test func makesViewState() {
        let fakeDate: Date = .init(timeIntervalSince1970: 123)

        mockPlayedWordsLibrary.words = [
            .init(id: .init(rawValue: "1"), word: "ABCDE", playedAt: fakeDate),
            .init(id: .init(rawValue: "2"), word: "QWXYZ", playedAt: fakeDate)
        ]

        let result = sut.make()
        
        #expect(
            result == .init(
                navigationTitle: "Words",
                cards: [
                    // Cards are keyed on the stored word's identity, not its list position.
                    .init(id: .init(rawValue: "1"), dateSection: .init(title: "Played on", date: fakeDate), word: "ABCDE", onTap: .fake),
                    .init(id: .init(rawValue: "2"), dateSection: .init(title: "Played on", date: fakeDate), word: "QWXYZ", onTap: .fake)
                ]
            )
        )
    }
    
    @Test func tapsOnWord() {
        let fakeDate: Date = .init(timeIntervalSince1970: 123)

        mockPlayedWordsLibrary.words = [
            .init(id: .init(rawValue: "1"), word: "ABCDE", playedAt: fakeDate),
            .init(id: .init(rawValue: "2"), word: "QWXYZ", playedAt: fakeDate)
        ]

        let result = sut.make()

        result.cards.first?.onTap.action()

        #expect(mockNavigationRouter.calls == [.push(destination: .wordMeaning(word: "ABCDE"))])
    }
    
}

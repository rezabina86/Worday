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
            .init(id: "1", word: "ABCDE", playedAt: fakeDate),
            .init(id: "2", word: "QWXYZ", playedAt: fakeDate)
        ]

        let result = sut.make()
        
        #expect(
            result == .init(
                navigationTitle: "Words",
                cards: [
                    .init(id: "0", dateSection: .init(title: "Played on", date: fakeDate), word: "ABCDE", onTap: .fake),
                    .init(id: "1", dateSection: .init(title: "Played on", date: fakeDate), word: "QWXYZ", onTap: .fake)
                ]
            )
        )
    }
    
    @Test func tapsOnWord() {
        let fakeDate: Date = .init(timeIntervalSince1970: 123)

        mockPlayedWordsLibrary.words = [
            .init(id: "1", word: "ABCDE", playedAt: fakeDate),
            .init(id: "2", word: "QWXYZ", playedAt: fakeDate)
        ]

        let result = sut.make()

        result.cards.first?.onTap.action()

        #expect(mockNavigationRouter.calls == [.push(destination: .wordMeaning(word: "ABCDE"))])
    }
    
}

import Testing
import Foundation
@testable import Worday

struct WordListViewStateConverterTests {
    
    let sut: WordListViewStateConverter
    let mockWordContext: WordStorageModelContextMock
    
    init() {
        mockWordContext = .init()
        sut = .init(wordContext: mockWordContext)
    }

    @Test func testCreate() async throws {
        let fakeDate: Date = .init(timeIntervalSince1970: 123)
        
        mockWordContext.fetchReturnValue = [
            .init(id: "1", word: "ABCDE", playedAt: fakeDate),
            .init(id: "2", word: "QWXYZ", playedAt: fakeDate)
        ]
        
        let result = sut.create()
        
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
    
}

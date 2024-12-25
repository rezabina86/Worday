import Testing
import Foundation
@testable import Worday

struct WordRepositoryTests {
    
    var sut: WordRepository!
    var mockWordService: WordServiceMock!
    
    init() {
        mockWordService = .init()
        
        sut = .init(wordService: mockWordService)
    }

    @Test func testLoad() async throws {
        let fakeEntity: WordEntity = .fake(commonWords: ["a", "b"])
        mockWordService.loadReturnValue = fakeEntity
        
        let expectedResult: WordModel = .fake(words: ["a", "b"])
        
        let words = try sut.words()
        #expect(words == expectedResult)
        #expect(mockWordService.calls == [.load])
    }
}

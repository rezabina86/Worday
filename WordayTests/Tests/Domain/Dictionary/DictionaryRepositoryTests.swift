import Testing
import Foundation
@testable import Worday

struct DictionaryRepositoryTests {
    
    var sut: DictionaryRepository
    var mockDictionaryService: DictionaryServiceMock
    
    init() {
        mockDictionaryService = .init()
        sut = .init(dictionaryService: mockDictionaryService)
    }
    
    @Test func testSuccess() async throws {
        mockDictionaryService.meaningReturnValue = .success([.fake()])
        
        let result = try await sut.meaning(for: "abcde")
        #expect(result == .fake())
        #expect(mockDictionaryService.calls == [.meaning(word: "abcde")])
    }
}

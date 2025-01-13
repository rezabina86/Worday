import Testing
import Foundation
@testable import Worday

struct DictionaryServiceTests {
    
    let sut: DictionaryService
    let mockHTTPClient: HTTPClientMock
    
    init() {
        mockHTTPClient = .init()
        sut = .init(client: mockHTTPClient)
    }
    
    @Test func testLoad() async throws {
        mockHTTPClient.loadReturnValue = .success([WordMeaningAPIEntity.fake()])
        
        let entity = try await sut.meaning(for: "abcde")
        
        #expect(entity == [.fake()])
    }
}

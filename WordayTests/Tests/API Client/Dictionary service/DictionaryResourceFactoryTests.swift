import Testing
import Foundation
@testable import Worday

final class DictionaryResourceFactoryTests {
    
    var sut: Resource<[WordMeaningAPIEntity]>!
    var mockDecoder: JSONDecoderMock!
    
    init() {
        mockDecoder = .init()
        mockDecoder.decodeReturnValue = [WordMeaningAPIEntity.fake()]
        DictionaryResourceFactory.decoder = mockDecoder
    }
    
    deinit {
        mockDecoder = nil
    }
    
    @Test func testGenerateURL() {
        sut = DictionaryResourceFactory.resource(for: "abcde")
        #expect(sut.url.absoluteString == "https://api.dictionaryapi.dev/api/v2/entries/en/abcde")
    }
    
    @Test func testMethod() {
        sut = DictionaryResourceFactory.resource(for: "abcde")
        #expect(sut.method == .get)
    }
    
    @Test func testParse() {
        sut = DictionaryResourceFactory.resource(for: "abcde")
        let result: [WordMeaningAPIEntity]!
        result = try? sut.parse(Data())
        
        #expect(result == [WordMeaningAPIEntity.fake()])
        #expect(mockDecoder.decodeCalls.compactMap{ $0.type }.count == 1)
    }
}

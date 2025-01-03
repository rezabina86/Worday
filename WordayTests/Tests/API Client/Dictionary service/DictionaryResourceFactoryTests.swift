import Testing
import Foundation
@testable import Worday

final class DictionaryResourceFactoryTests {
    
    var sut: Resource<[WordMeaningAPIEntity]>!
    var mockDecoder: JSONDecoderMock!
    
    init() {
        mockDecoder = .init()
        mockDecoder.decodeReturnValue = [WordMeaningAPIEntity.fake()]
    }
    
    deinit {
        mockDecoder = nil
    }
    
    @Test func testGenerateURL() {
        DictionaryResourceFactory.decoder = mockDecoder
        sut = DictionaryResourceFactory.resource(for: "abcde")
        #expect(sut.url.absoluteString == "https://api.dictionaryapi.dev/api/v2/entries/en/abcde")
    }
    
    @Test func testMethod() {
        DictionaryResourceFactory.decoder = mockDecoder
        sut = DictionaryResourceFactory.resource(for: "abcde")
        #expect(sut.method == .get)
    }
    
    @Test func testParse() {
        DictionaryResourceFactory.decoder = mockDecoder
        sut = DictionaryResourceFactory.resource(for: "abcde")
        let result: [WordMeaningAPIEntity]!
        result = try? sut.parse(Data())
        
        #expect(result == [WordMeaningAPIEntity.fake()])
    }
}

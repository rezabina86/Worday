import Testing
import Foundation
@testable import Worday

struct DictionaryResourceFactoryTests {

    private let mockDecoder: JSONDecoderMock

    init() {
        mockDecoder = .init()
        mockDecoder.decodeReturnValue = [WordMeaningAPIEntity.fake()]
    }

    @Test func generatesURL() {
        let sut = DictionaryResourceFactory.resource(for: "abcde")
        #expect(sut?.url.absoluteString == "https://api.dictionaryapi.dev/api/v2/entries/en/abcde")
    }

    @Test func usesGetMethod() {
        let sut = DictionaryResourceFactory.resource(for: "abcde")
        #expect(sut?.method == .get)
    }

    @Test func parsesTheResponseWithTheInjectedDecoder() throws {
        let sut = DictionaryResourceFactory.resource(for: "abcde", decoder: mockDecoder)
        let result = try sut?.parse(Data())
        #expect(result == [WordMeaningAPIEntity.fake()])
    }
}

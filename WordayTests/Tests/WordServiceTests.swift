import Testing
@testable import Worday

struct WordayTests {
    
    var sut: WordService!
    var mockResourceLoader: ResourceLoaderMock!
    
    init() {
        mockResourceLoader = .init()
        mockResourceLoader.loadResourceReturnValue = wordsReturnValue.data(using: .utf8)!
        sut = .init(resourceLoader: mockResourceLoader)
    }
    
    let expectedEntity: WordEntity = .init(commonWords: ["right", "tibet"])

    @Test func testLoad() async throws {
        let words = try sut.load()
        #expect(words == expectedEntity)
        #expect(mockResourceLoader.calls == [.loadResource(name: "common", ext: "json")])
    }

}

private let wordsReturnValue = """
{
  "description": "Common English words.",
  "commonWords":["right","tibet"]
}
"""

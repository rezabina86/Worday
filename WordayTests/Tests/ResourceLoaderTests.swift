import Testing
import Foundation
@testable import Worday

struct ResourceLoaderTests {
    
    var sut: ResourceLoader!
    var mockBundle: BundleMock!
    var mockURLContentLoader: URLContentLoaderMock!
    
    init() {
        mockBundle = .init()
        mockURLContentLoader = .init()
        sut = .init(
            bundle: mockBundle,
            urlContentLoader: mockURLContentLoader
        )
    }

    @Test func load() async throws {
        let fakeURL = URL(string: "http://example.com/")!
        mockBundle.urlForResourceReturn = fakeURL
        mockURLContentLoader.contentReturnValue = fakeData
        
        let data = try sut.loadResource(named: "common", withExtension: "json")
        #expect(data == fakeData)
        #expect(mockBundle.calls == [.url(forResource: "common", withExtension: "json")])
        #expect(mockURLContentLoader.calls == [.content(url: fakeURL)])
    }
}

private let fakeData = """
{
  "description": "Common English words.",
  "commonWords":["right","tibet"]
}
""".data(using: .utf8)!

import Testing
import Foundation
@testable import Worday

struct InfoModalViewStateConverterTests {
    let sut: InfoModalViewStateConverter
    let mockBundle: BundleMock
    
    init() {
        mockBundle = .init()
        sut = .init(bundle: mockBundle)
    }

    @Test func testCreate() async throws {
        mockBundle.version = "1.3.0"
        mockBundle.build = "1"
        let result = sut.create()
        
        #expect(
            result == .init(
                topics: [
                    "Each day, the game provides a new word for you to guess.",
                    "Rearrange the letters to form the correct word.",
                    "The color of the tiles will change to show how close your guess was to the word.",
                    "Once you've guessed the word, its meaning will be revealed."
                ],
                versionString: "Version 1.3.0 (1)"
            )
        )
    }
}

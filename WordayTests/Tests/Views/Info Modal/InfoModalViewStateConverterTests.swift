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

    @Test func makesViewState() {
        mockBundle.version = "1.3.0"
        mockBundle.build = "1"
        let result = sut.make()

        #expect(result.topics == [
            "Each day, the game provides a new word for you to guess.",
            "Rearrange the letters to form the correct word.",
            "The color of the tiles will change to show how close your guess was to the word.",
            "Once you've guessed the word, its meaning will be revealed."
        ])
        #expect(result.versionString == "Version 1.3.0 (1)")
    }

    @Test("the acknowledgements carry the licence-required dictionary attribution")
    func includesRequiredDictionaryAttribution() {
        let acknowledgements = sut.make().acknowledgements
        let bodies = acknowledgements.sections.map(\.body).joined(separator: " ")

        #expect(acknowledgements.title == "Acknowledgements")
        // Wiktionary (CC BY-SA) attribution + link
        #expect(bodies.contains("CC BY-SA 4.0"))
        #expect(acknowledgements.sections.contains {
            $0.link == URL(string: "https://www.wiktionary.org")
        })
        // Princeton WordNet copyright notice
        #expect(bodies.contains("Copyright 2006 by Princeton University"))
        #expect(acknowledgements.sections.contains {
            $0.link == URL(string: "https://wordnet.princeton.edu")
        })
    }
}

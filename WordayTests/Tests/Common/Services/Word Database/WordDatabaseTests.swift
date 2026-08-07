import Testing
import Foundation
@testable import Worday

struct WordDatabaseTests {

    // MARK: - Unit (mocked bundle)

    private let sampleJSON = """
    {
      "version": 1,
      "answers": ["abbey", "crane"],
      "valid": ["abbey", "crane", "cores"],
      "definitions": {
        "abbey": { "meanings": [
          { "pos": "noun", "definitions": ["a church"] }
        ] },
        "crane": { "meanings": [
          { "pos": "noun", "definitions": ["a bird", "a machine"] },
          { "pos": "verb", "definitions": ["to stretch"] }
        ] }
      }
    }
    """

    private func makeSUT(json: String) -> (WordDatabase, ResourceLoaderMock) {
        let loader = ResourceLoaderMock()
        loader.loadResourceReturnValue = Data(json.utf8)
        return (WordDatabase(resourceLoader: loader, decoder: JSONDecoder()), loader)
    }

    @Test func loadsTheAnswerPoolFromTheBundledResource() {
        let (sut, loader) = makeSUT(json: sampleJSON)
        #expect(sut.answerWords() == ["abbey", "crane"])
        #expect(loader.calls == [.loadResource(name: "dictionary", ext: "json")])
    }

    @Test func validityChecksAgainstTheFullValidSet() {
        let (sut, _) = makeSUT(json: sampleJSON)
        #expect(sut.isValid("cores"))      // valid but not an answer
        #expect(sut.isValid("abbey"))
        #expect(!sut.isValid("zzzzz"))
    }

    @Test func meaningMapsAllSensesGroupedByPartOfSpeech() {
        let (sut, _) = makeSUT(json: sampleJSON)
        #expect(sut.meaning(for: "crane") == WordMeaningModel(
            word: "crane",
            meanings: [
                .init(partOfSpeech: .noun, definitions: [
                    .init(definition: "a bird"), .init(definition: "a machine")]),
                .init(partOfSpeech: .verb, definitions: [.init(definition: "to stretch")])
            ]))
    }

    @Test func returnsNilMeaningForAValidButUndefinedWord() {
        let (sut, _) = makeSUT(json: sampleJSON)
        #expect(sut.meaning(for: "cores") == nil)
        #expect(sut.meaning(for: "zzzzz") == nil)
    }

    @Test func unknownPartOfSpeechFallsBackToNoun() {
        let json = """
        {"version":1,"answers":["abcde"],"valid":["abcde"],
         "definitions":{"abcde":{"meanings":[{"pos":"nonsense","definitions":["x"]}]}}}
        """
        let (sut, _) = makeSUT(json: json)
        #expect(sut.meaning(for: "abcde")?.meanings.first?.partOfSpeech == .noun)
    }

    // MARK: - Integrity (the real shipped dictionary.json)

    @Test("every shipped answer is valid and resolves to a meaning")
    func shippedBundleSatisfiesTheOfflineInvariants() {
        let container = Container()
        injectDependencies(into: container)
        let db = container.resolve() as WordDatabaseType

        let answers = db.answerWords()
        #expect(!answers.isEmpty)
        for word in answers {
            #expect(word.count == 5, "answer '\(word)' is not 5 letters")
            #expect(word.allSatisfy { $0.isLetter && $0.isLowercase }, "answer '\(word)' not a–z")
            #expect(db.isValid(word), "answer '\(word)' missing from the valid set")
            guard let meaning = db.meaning(for: word) else {
                Issue.record("answer '\(word)' has no offline meaning")
                continue
            }
            #expect(!meaning.meanings.isEmpty, "answer '\(word)' has no senses")
            #expect(meaning.meanings.allSatisfy { !$0.definitions.isEmpty },
                    "answer '\(word)' has a sense with no definitions")
        }
    }
}

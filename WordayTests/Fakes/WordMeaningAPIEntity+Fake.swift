@testable import Worday

extension WordMeaningAPIEntity {
    static func fake(word: String = "word",
                     meanings: [Meaning] = [.fake()]) -> Self {
        .init(word: word,
              meanings: meanings)
    }
}

extension WordMeaningAPIEntity.Meaning {
    static func fake(partOfSpeech: PartOfSpeech = .noun,
                     definitions: [Definition] = [.fake()]) -> Self {
        .init(partOfSpeech: partOfSpeech,
              definitions: definitions)
    }
}

extension WordMeaningAPIEntity.Meaning.Definition {
    static func fake(definition: String = "definition") -> Self {
        .init(definition: definition)
    }
}


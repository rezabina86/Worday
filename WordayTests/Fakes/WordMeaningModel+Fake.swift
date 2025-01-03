@testable import Worday

extension WordMeaningModel {
    static func fake(word: String = "word",
                     meanings: [Meaning] = [.fake()]) -> Self {
        .init(word: word,
              meanings: meanings)
    }
}

extension WordMeaningModel.Meaning {
    static func fake(partOfSpeech: PartOfSpeech = .noun,
                     definitions: [Definition] = [.fake()]) -> Self {
        .init(partOfSpeech: partOfSpeech,
              definitions: definitions)
    }
}

extension WordMeaningModel.Meaning.Definition {
    static func fake(definition: String = "definition") -> Self {
        .init(definition: definition)
    }
}


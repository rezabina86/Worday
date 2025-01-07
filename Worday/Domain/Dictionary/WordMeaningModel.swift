import Foundation

struct WordMeaningModel: Equatable {
    let word: String
    let meanings: [Meaning]
}

extension WordMeaningModel {
    struct Meaning: Equatable {
        let partOfSpeech: PartOfSpeech
        let definitions: [Definition]
    }
}

extension WordMeaningModel.Meaning {
    enum PartOfSpeech: String, Equatable {
        case noun
        case verb
        case adjective
        case adverb
        case pronoun
        case preposition
        case conjunction
        case interjection
        case numeral
        case article
        case determiner
    }
    
    struct Definition: Equatable {
        let definition: String
    }
}


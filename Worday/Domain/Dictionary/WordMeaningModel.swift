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
        case interjection
    }
    
    struct Definition: Equatable {
        let definition: String
    }
}


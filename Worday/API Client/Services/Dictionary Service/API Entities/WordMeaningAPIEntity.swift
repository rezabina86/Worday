import Foundation

struct WordMeaningAPIEntity: Decodable, Equatable {
    let word: String
    let meanings: [Meaning]
}

extension WordMeaningAPIEntity {
    struct Meaning: Decodable, Equatable {
        let partOfSpeech: PartOfSpeech
        let definitions: [Definition]
    }
}

extension WordMeaningAPIEntity.Meaning {
    enum PartOfSpeech: String, Decodable, Equatable {
        case noun
        case verb
        case interjection
    }
    
    struct Definition: Decodable, Equatable {
        let definition: String
    }
}

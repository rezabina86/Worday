import Foundation

struct DictionaryResourceFactory: ResourceFactoryType {
    
    static var decoder: DecoderType = jsonDecoder
    
    static func resource(for word: String) -> Resource<[WordMeaningAPIEntity]>? {
        return url(for: word)
        .flatMap {
            .get(
                url: $0,
                using: decoder
            )
        }
    }
    
    private static func url(for word: String) -> URL? {
        .init(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)")
    }
}

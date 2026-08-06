import Foundation

struct DictionaryResourceFactory: ResourceFactoryType {

    static func resource(
        for word: String,
        decoder: DecoderType = jsonDecoder
    ) -> Resource<[WordMeaningAPIEntity]>? {
        url(for: word)
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

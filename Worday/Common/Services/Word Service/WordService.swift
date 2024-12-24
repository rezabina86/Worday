import Foundation

protocol WordServiceType {
    func load() throws -> WordEntity
}

final class WordService: WordServiceType {
    
    init(resourceLoader: ResourceLoaderType) {
        self.resourceLoader = resourceLoader
    }
    
    func load() throws -> WordEntity {
        let data = try resourceLoader.loadResource(named: "common", withExtension: "json")
        return try JSONDecoder().decode(WordEntity.self, from: data)
    }
    
    private let resourceLoader: ResourceLoaderType
}

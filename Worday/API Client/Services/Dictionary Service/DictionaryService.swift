import Foundation

protocol DictionaryServiceType {
    func meaning(for word: String) async throws -> [WordMeaningAPIEntity]
}

struct DictionaryService: DictionaryServiceType {
    
    init(client: HTTPClientType) {
        self.client = client
    }
    
    func meaning(for word: String) async throws -> [WordMeaningAPIEntity] {
        guard let resource = DictionaryResourceFactory.resource(for: word) else {
            throw ResourceError.invalidParameters
        }
        
        return try await client.load(resource: resource)
    }
    
    // MARK: - Privates
    private let client: HTTPClientType
}

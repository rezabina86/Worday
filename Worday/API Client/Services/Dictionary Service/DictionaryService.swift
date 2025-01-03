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
        
        let result = try await client.load(resource: resource)
        
        return await MainActor.run {
            return result
        }
    }
    
    // MARK: - Privates
    private let client: HTTPClientType
}

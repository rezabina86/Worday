@testable import Worday

final class DictionaryServiceMock: DictionaryServiceType {
    
    enum Call: Equatable {
        case meaning(word: String)
    }
    
    func meaning(for word: String) async throws -> [WordMeaningAPIEntity] {
        calls.append(.meaning(word: word))
        switch meaningReturnValue {
        case let .success(entity):
            return entity
        case let .failure(error):
            throw error
        }
    }
    
    var calls: [Call] = []
    var meaningReturnValue: Result<[WordMeaningAPIEntity], Error> = .success([])
}

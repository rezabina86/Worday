@testable import Worday

final class DictionaryServiceMock: DictionaryServiceType {
    
    enum Call: Equatable {
        case meaning(word: String)
    }
    
    func meaning(for word: String) async throws -> [WordMeaningAPIEntity] {
        calls.append(.meaning(word: word))
        return meaningReturnValue
    }
    
    var calls: [Call] = []
    var meaningReturnValue: [WordMeaningAPIEntity] = []
}

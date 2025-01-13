@testable import Worday

final class DictionaryRepositoryMock: DictionaryRepositoryType {
    
    enum Call: Equatable {
        case meaning(word: String)
    }
    
    func meaning(for word: String) async throws -> WordMeaningModel {
        calls.append(.meaning(word: word))
        return meaningReturnValue
    }
    
    var calls: [Call] = []
    var meaningReturnValue: WordMeaningModel = .fake()
}

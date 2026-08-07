@testable import Worday

final class DictionaryRepositoryMock: DictionaryRepositoryType {

    enum Call: Equatable {
        case meaning(word: String)
    }

    func meaning(for word: String) async throws -> WordMeaningModel {
        calls.append(.meaning(word: word))
        if let meaningThrows { throw meaningThrows }
        return meaningReturnValue
    }

    private(set) var calls: [Call] = []
    var meaningReturnValue: WordMeaningModel = .fake()
    var meaningThrows: Error?
}

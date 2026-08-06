import Foundation
@testable import Worday

final class DictionaryUseCaseMock: DictionaryUseCaseType {

    enum Call: Equatable {
        case meaning(word: String)
    }

    func meaning(for word: String) async -> DictionaryDataState {
        calls.append(.meaning(word: word))
        return meaningReturnValue
    }

    private(set) var calls: [Call] = []
    var meaningReturnValue: DictionaryDataState = .loading
}

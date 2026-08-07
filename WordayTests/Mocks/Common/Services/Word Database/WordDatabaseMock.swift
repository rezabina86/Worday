import Foundation
@testable import Worday

final class WordDatabaseMock: WordDatabaseType, @unchecked Sendable {

    // MARK: - Publics

    enum Call: Equatable {
        case answerWords
        case isValid(word: String)
        case meaning(word: String)
    }

    func answerWords() -> [String] {
        calls.append(.answerWords)
        return answerWordsReturnValue
    }

    func isValid(_ word: String) -> Bool {
        calls.append(.isValid(word: word))
        return isValidReturnValue
    }

    func meaning(for word: String) -> WordMeaningModel? {
        calls.append(.meaning(word: word))
        return meaningReturnValue
    }

    // MARK: - Privates

    private(set) var calls: [Call] = []
    var answerWordsReturnValue: [String] = []
    var isValidReturnValue: Bool = false
    var meaningReturnValue: WordMeaningModel?
}

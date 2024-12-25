@testable import Worday
import Foundation

extension WordModel {
    static func fake(words: [String] = []) -> WordModel {
        .init(words: words)
    }
}


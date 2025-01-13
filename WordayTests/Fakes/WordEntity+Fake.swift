@testable import Worday

extension WordEntity {
    static func fake(commonWords: [String] = []) -> WordEntity {
        .init(commonWords: commonWords)
    }
}


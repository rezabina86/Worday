import Foundation

protocol ArrayShuffleType {
    func shuffle(array: [String]) -> [String]
}

struct ArrayShuffle: ArrayShuffleType {
    func shuffle(array: [String]) -> [String] {
        array.shuffled()
    }
}


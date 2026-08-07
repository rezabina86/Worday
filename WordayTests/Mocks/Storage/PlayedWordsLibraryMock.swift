@testable import Worday

final class PlayedWordsLibraryMock: PlayedWordsLibraryType {

    enum Call: Equatable {
        case load
        case reload
    }

    var words: [WordStorageEntity] = []

    func load() {
        calls.append(.load)
    }

    func reload() {
        calls.append(.reload)
    }

    private(set) var calls: [Call] = []
}

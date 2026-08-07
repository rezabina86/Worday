@testable import Worday

final class PlayedWordsLibraryMock: PlayedWordsLibraryType {

    enum Call: Equatable {
        case reload
    }

    var words: [WordStorageEntity] = []

    func reload() {
        calls.append(.reload)
    }

    private(set) var calls: [Call] = []
}

import Foundation
@testable import Worday

final class WordMeaningViewModelMock: WordMeaningViewModelType {

    enum Call: Equatable {
        case load
    }

    var viewState: WordMeaningViewState = .loading

    func load() async {
        calls.append(.load)
    }

    private(set) var calls: [Call] = []
}

import Foundation
@testable import Worday

final class InfoModalViewStateConverterMock: InfoModalViewStateConverterType {

    enum Call: Equatable {
        case make
    }

    func make() -> InfoModalViewState {
        calls.append(.make)
        return makeReturnValue
    }

    private(set) var calls: [Call] = []
    var makeReturnValue: InfoModalViewState = .init(
        topics: [],
        versionString: "",
        acknowledgements: .init(title: "", sections: []),
        dismiss: .fake)
}

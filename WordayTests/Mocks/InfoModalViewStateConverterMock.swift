import Foundation
@testable import Worday

final class InfoModalViewStateConverterMock: InfoModalViewStateConverterType {
    enum Call: Equatable {
        case create
    }
    
    func create() -> InfoModalViewState {
        calls.append(.create)
        return createReturnValue
    }
    
    var calls: [Call] = []
    var createReturnValue: InfoModalViewState = .init(topics: [], versionString: "")
}

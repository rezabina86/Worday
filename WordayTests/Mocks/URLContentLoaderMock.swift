@testable import Worday
import Foundation

final class URLContentLoaderMock: URLContentLoaderType {
    
    enum Call: Equatable {
        case content(url: URL)
    }
    
    func content(of url: URL) throws -> Data {
        calls.append(.content(url: url))
        return contentReturnValue
    }
    
    var calls: [Call] = []
    var contentReturnValue: Data!
}

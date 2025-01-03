import Foundation
@testable import Worday

final class URLSessionFactoryMock: URLSessionFactoryType {
    
    enum Call: Equatable {
        case createURLSession(extendedCache: Bool, preventRedirects: Bool)
    }
    
    var calls: [Call] = []
    var createURLSessionReturnValue: URLSessionMock = .init()
    
    func createURLSession(extendedCache: Bool, preventRedirects: Bool) -> URLSessionType {
        calls.append(.createURLSession(extendedCache: extendedCache, preventRedirects: preventRedirects))
        return createURLSessionReturnValue
    }
}

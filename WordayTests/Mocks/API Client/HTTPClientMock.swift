import Foundation
@testable import Worday

final class HTTPClientMock: HTTPClientType {
    
    enum Call: Equatable {
        case load(url: URL, method: HTTPMethod, additionalHeaders: HTTPHeaders?)
    }
    
    var calls: [Call] = []
    var loadReturnValue: Result<Decodable, Error> = .failure(NSError(domain: "", code: 0))
    
    func load<Entity>(resource: Resource<Entity>) async throws -> Entity {
        calls.append(.load(
            url: resource.url,
            method: resource.method,
            additionalHeaders: resource.additionalHeaders
        ))
        
        switch loadReturnValue {
        case let .success(result):
            return result as! Entity
        case let .failure(error):
            throw error
        }
    }
    
}

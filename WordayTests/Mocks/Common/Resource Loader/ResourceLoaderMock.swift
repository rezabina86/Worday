import Foundation
@testable import Worday

final class ResourceLoaderMock: ResourceLoaderType {
    
    enum Call: Equatable {
        case loadResource(name: String, ext: String)
    }
    
    func loadResource(named name: String, withExtension ext: String) throws -> Data {
        calls.append(.loadResource(name: name, ext: ext))
        if let loadResourceThrows {
            throw loadResourceThrows
        }
        return loadResourceReturnValue
    }
    
    var calls: [Call] = []
    var loadResourceReturnValue: Data!
    var loadResourceThrows: ResourceLoaderError?
}

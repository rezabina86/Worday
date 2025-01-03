import Foundation
@testable import Worday

final class JSONDecoderMock: DecoderType {
    
    var decodeCalls: [(type: Any, data: Data)] = []
    var decodeReturnValue: Any!
    var decodeReturnRule: ((Data) -> Any)?
    var decodeError: Error?
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        decodeCalls.append((type, data))
        if let decodeError {
            throw decodeError
        }
        let object = decodeReturnRule?(data) ?? decodeReturnValue
        return object as! T
    }
}

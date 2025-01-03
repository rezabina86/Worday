import Foundation
@testable import Worday

final class JSONEncoderMock: EncoderType {
    
    var encodeCalls: [Any] = []
    var encodeReturnValue: Data!
    var encodeReturnRule: ((Encodable) -> Data)?
    var encodeError: Error?
    
    func encode<T>(_ value: T) throws -> Data where T : Encodable {
        encodeCalls.append(value)
        if let encodeError {
            throw encodeError
        }
        return encodeReturnRule?(value) ?? encodeReturnValue
    }
    
}

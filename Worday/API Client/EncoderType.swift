import Foundation

protocol EncoderType: AnyObject {
    func encode<T: Encodable>(_ value: T) throws -> Data
}

extension JSONEncoder: EncoderType {}

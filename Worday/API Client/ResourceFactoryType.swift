import Foundation

protocol ResourceFactoryType {
    static var jsonDecoder: DecoderType { get }
    static var jsonEncoder: EncoderType { get }
}

extension ResourceFactoryType {
    static var jsonDecoder: DecoderType {
        decoder
    }
    
    static var jsonEncoder: EncoderType {
        encoder
    }
}

// MARK: - JSONDecoder
private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    return decoder
}()

// MARK: - JSONEncoder
private let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    return encoder
}()

import Foundation

/// A resource describes one endpoint. It knows where to retrieve the data from by
/// its `url` property and how to transform the data returned to a client side
/// representation using its `parse` method.
public struct Resource<Entity>: Equatable {
    // MARK: Lifecycle

    init(url: URL, method: HTTPMethod = .get, additionalHeaders: HTTPHeaders? = nil, parse: @escaping (Data?) throws -> Entity) {
        self.url = url
        self.method = method
        self.additionalHeaders = additionalHeaders
        self.parse = parse
    }

    // MARK: Public

    public enum Error: Swift.Error {
        case dataMissing
        case dataCorrupted
    }

    public static func == (lhs: Resource<Entity>, rhs: Resource<Entity>) -> Bool {
        return lhs.additionalHeaders == rhs.additionalHeaders
            && lhs.method == rhs.method
            && lhs.url == rhs.url
    }

    // MARK: Internal

    let url: URL
    let method: HTTPMethod
    let additionalHeaders: HTTPHeaders?
    let parse: (Data?) throws -> Entity

    // MARK: Get
    static func get<DecodableEntity: Decodable>(url: URL, additionalHeaders: HTTPHeaders? = nil, using decoder: DecoderType) -> Resource<DecodableEntity> {
        return Resource<DecodableEntity>(
            url: url,
            method: .get,
            additionalHeaders: additionalHeaders,
            parse: { data in
                guard let data = data else { throw Error.dataMissing }
                return try decoder.decode(DecodableEntity.self, from: data)
            }
        )
    }

    static func get<APIEntity: Decodable>(url: URL, additionalHeaders: HTTPHeaders? = nil, keyPath: KeyPath<APIEntity, Entity>, using decoder: DecoderType) -> Resource<Entity> {
        return Resource<Entity>(
            url: url,
            method: .get,
            additionalHeaders: additionalHeaders,
            parse: { data in
                guard let data = data else { throw Error.dataMissing }
                return try decoder.decode(APIEntity.self, from: data)[keyPath: keyPath]
            }
        )
    }

    // MARK: Delete
    static func delete<RequestEntity: Encodable>(url: URL, entity: RequestEntity, additionalHeaders: HTTPHeaders? = nil, encoder: EncoderType) -> Resource<Void>? {
        guard let data = try? encoder.encode(entity) else {
            return nil
        }

        return Resource<Void>(
            url: url,
            method: .delete(data),
            additionalHeaders: additionalHeaders,
            parse: { _ in }
        )
    }

    static func delete(url: URL, additionalHeaders: HTTPHeaders? = nil) -> Resource<Void>? {
        handleRequest(with: .delete(nil),
                      url: url,
                      additionalHeaders: additionalHeaders)
    }

    // MARK: Post
    static func post<RequestEntity: Encodable>(url: URL, entity: RequestEntity, additionalHeaders: HTTPHeaders? = nil, encoder: EncoderType) -> Resource<Void>? {
        guard let data = try? encoder.encode(entity) else {
            return nil
        }

        return Resource<Void>(
            url: url,
            method: .post(data),
            additionalHeaders: additionalHeaders,
            parse: { _ in }
        )
    }

    static func post<RequestEntity: Encodable, ResponseEntity: Decodable>(url: URL, requiresAuthentication: Bool = true, entity: RequestEntity, additionalHeaders: HTTPHeaders? = nil, encoder: EncoderType, decoder: DecoderType) -> Resource<ResponseEntity>? {
        guard let data = try? encoder.encode(entity) else {
            return nil
        }

        return Resource<ResponseEntity>(
            url: url,
            method: .post(data),
            additionalHeaders: additionalHeaders,
            parse: { data in
                guard let data = data else { throw Error.dataMissing }
                return try decoder.decode(ResponseEntity.self, from: data)
            }
        )
    }

    static func post<ResponseEntity: Decodable>(url: URL, requiresAuthentication: Bool = true, additionalHeaders: HTTPHeaders? = nil, using decoder: DecoderType) -> Resource<ResponseEntity> {
        return Resource<ResponseEntity>(
            url: url,
            method: .post(nil),
            additionalHeaders: additionalHeaders,
            parse: { data in
                guard let data = data else { throw Error.dataMissing }
                return try decoder.decode(ResponseEntity.self, from: data)
            }
        )
    }

    static func post<RequestEntity: Encodable, ResponseEntity: Decodable>(url: URL, requiresAuthentication: Bool = true, entity: RequestEntity, additionalHeaders: HTTPHeaders? = nil, keyPath: KeyPath<ResponseEntity, Entity>, encoder: EncoderType, decoder: DecoderType) -> Resource<Entity>? {
        guard let data = try? encoder.encode(entity) else {
            return nil
        }

        return Resource<Entity>(
            url: url,
            method: .post(data),
            additionalHeaders: additionalHeaders,
            parse: { data in
                guard let data = data else { throw Error.dataMissing }
                return try decoder.decode(ResponseEntity.self, from: data)[keyPath: keyPath]
            }
        )
    }

    // MARK: Put
    static func put<RequestEntity: Encodable>(url: URL, requiresAuthentication: Bool = true, entity: RequestEntity, additionalHeaders: HTTPHeaders? = nil, encoder: EncoderType) -> Resource<Void>? {
        guard let data = try? encoder.encode(entity) else {
            return nil
        }

        return handleRequest(with: .put(data),
                             url: url,
                             additionalHeaders: additionalHeaders)
    }

    // MARK: Patch
    static func patch<RequestEntity: Encodable>(url: URL, requiresAuthentication: Bool = true, entity: RequestEntity, additionalHeaders: HTTPHeaders? = nil, encoder: EncoderType) -> Resource<Void>? {
        guard let data = try? encoder.encode(entity) else {
            return nil
        }

        return handleRequest(with: .patch(data),
                             url: url,
                             additionalHeaders: additionalHeaders)
    }

    // MARK: Private

    private static func handleRequest(with httpMethod: HTTPMethod,
                                      url: URL,
                                      additionalHeaders: HTTPHeaders?) -> Resource<Void>? {
        return Resource<Void>(
            url: url,
            method: httpMethod,
            parse: { _ in }
        )
    }
}

/// Represents a http method to be used in conjunction
/// with a resource
public enum HTTPMethod: Equatable {
    case get
    case post(Data?)
    case put(Data?)
    case delete(Data?)
    case patch(Data?)

    // MARK: Internal

    /// Returns the appropriate HTTP Method string
    var httpMethod: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        case .patch: return "PATCH"
        }
    }

    var body: Data? {
        switch self {
        case let .post(body), let .put(body), let .patch(body), let .delete(body):
            return body
        case .get:
            return nil
        }
    }

    var canHaveBody: Bool {
        switch self {
        case .post, .put, .patch, .delete:
            return true
        case .get:
            return false
        }
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

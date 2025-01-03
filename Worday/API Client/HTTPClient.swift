import Foundation

typealias HTTPHeaders = [String: String]

extension URL {
    func relativeTo(baseURL: URL) -> URL? {
        return URL(string: absoluteString, relativeTo: baseURL)
    }
}

/// A protocol that handles basic HTTP communication
protocol HTTPClientType {
    /// Load an endpoint described by `resource`
    func load<Entity>(resource: Resource<Entity>) async throws -> Entity
}

final class HTTPClient: HTTPClientType {
    // MARK: Lifecycle

    public init(sessionFactory: URLSessionFactoryType,
                extendedCache: Bool) {
        session = sessionFactory.createURLSession(extendedCache: extendedCache, preventRedirects: false)
    }

    // MARK: Public

    public enum Error: Swift.Error, Equatable {
        case invalidRequestUrl
        case invalidResponse
        case notAuthorized
        case http(code: Int, data: Data?, headers: HTTPHeaders)
        case unknown
    }
    
    func load<Entity>(resource: Resource<Entity>) async throws -> Entity {
        guard resource.url.isValid else {
            throw Error.invalidRequestUrl
        }
        
        let request = createRequest(url: resource.url, method: resource.method, headers: resource.additionalHeaders)
        
        let data = try await performRequest(request)
        return try resource.parse(data)
    }

    // MARK: Private

    private let session: URLSessionType

    private func createRequest(url: URL, method: HTTPMethod, headers: HTTPHeaders?) -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.httpMethod
        request.httpBody = method.body
        return request
    }
    
    private func performRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(with: request)
        return try handleResponse(data: data, response: response)
    }
}

// MARK: - Handlers
private func handleResponse(data: Data, response: URLResponse) throws -> Data {
    guard let response = response as? HTTPURLResponse else {
        throw HTTPClient.Error.invalidResponse
    }

    let headers = response.allHeaderFields as? HTTPHeaders ?? [:]

    guard (200..<400).contains(response.statusCode) else {
        throw parseError(code: response.statusCode, data: data, headers: headers)
    }

    return data
}

// MARK: - Server Error Parsing
private func parseError(code: Int, data: Data?, headers: HTTPHeaders) -> Swift.Error {
    return parseHTTPError(code: code, data: data, headers: headers)
}

private func parseHTTPError(code: Int, data: Data?, headers: HTTPHeaders) -> Swift.Error {
    switch code {
    case 403: return HTTPClient.Error.notAuthorized
    default: return HTTPClient.Error.http(code: code, data: data, headers: headers)
    }
}

// MARK: - JSONDecoder
private let decoder = JSONDecoder()

extension URL {
    var isValid: Bool {
        return URLComponents(url: self, resolvingAgainstBaseURL: true)?.url != nil
    }
}

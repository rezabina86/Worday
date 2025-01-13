import Foundation

public protocol URLSessionFactoryType {
    func createURLSession(extendedCache: Bool, preventRedirects: Bool) -> URLSessionType
}

struct URLSessionFactory: URLSessionFactoryType {
    // MARK: Lifecycle

    init() {
        defaultHeaders = createDefaultHeaders()
    }

    // MARK: Internal

    func createURLSession(extendedCache: Bool, preventRedirects: Bool) -> URLSessionType {
        let configuration = URLSessionConfiguration.default

        if extendedCache {
            // https://developer.apple.com/documentation/foundation/nsurlsessiondatadelegate/1411612-urlsession#discussion
            // Based on the documentation and observation, large requests are not cached by the default cache.
            // Responses bigger than ~5% of the cache size are not cached by the standard URLSession behaviour.
            // As we load the graph for one language at one, this response might easily be bigger than 1MB, thus
            // we should create a cache big enough to hold this.
            configuration.urlCache = URLCache(memoryCapacity: .cacheMemoryCapacity,
                                              diskCapacity: .cacheDiskCapacity,
                                              diskPath: nil)
        }

        configuration.httpAdditionalHeaders = defaultHeaders

        return URLSession(configuration: configuration,
                          delegate: preventRedirects ? RedirectionPreventer() : nil,
                          delegateQueue: nil)
    }

    // MARK: Private

    private let defaultHeaders: [String: String]
}

private final class RedirectionPreventer: NSObject, URLSessionTaskDelegate {
    func urlSession(_: URLSession,
                    task _: URLSessionTask,
                    willPerformHTTPRedirection _: HTTPURLResponse,
                    newRequest _: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

// MARK: - Factories
private func createDefaultHeaders() -> [String: String] {
    return [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
}

// MARK: - Constants
private extension Int {
    static let cacheMemoryCapacity = 1000 * 1000 * 20
    static let cacheDiskCapacity = 1000 * 1000 * 80
}

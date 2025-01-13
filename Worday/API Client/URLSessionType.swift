import Foundation

public protocol URLSessionType {
    var configuration: URLSessionConfiguration { get }
    var delegate: URLSessionDelegate? { get }
    
    func data(with request: URLRequest) async throws -> (Data, URLResponse)
    func download(with request: URLRequest) async throws -> (URL, URLResponse)
    func upload(with request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionType {
    
    public func data(with request: URLRequest) async throws -> (Data, URLResponse) {
        try await self.data(for: request)
    }
    
    public func download(with request: URLRequest) async throws -> (URL, URLResponse) {
        try await self.download(for: request)
    }
    
    public func upload(with request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        try await self.upload(for: request, from: bodyData)
    }
}

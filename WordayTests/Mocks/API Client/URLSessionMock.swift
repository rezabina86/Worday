import Foundation
@testable import Worday

final class URLSessionMock: URLSessionType {
    
    enum Call: Equatable {
        case data(request: URLRequest)
        case upload(request: URLRequest, from: Data)
        case download(request: URLRequest)
    }
    
    var calls: [Call] = []
    
    var dataReturnValue: Result<(Data, URLResponse), Error> = .failure(NSError(domain: "", code: 0))
    var downloadReturnValue: Result<(URL, URLResponse), Error> = .failure(NSError(domain: "", code: 0))
    var uploadReturnValue: Result<(Data, URLResponse), Error> = .failure(NSError(domain: "", code: 0))
    
    var configuration: URLSessionConfiguration {
        .default
    }
    
    var delegate: URLSessionDelegate? {
        nil
    }
    
    func data(with request: URLRequest) async throws -> (Data, URLResponse) {
        calls.append(.data(request: request))
        switch dataReturnValue {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
    
    func download(with request: URLRequest) async throws -> (URL, URLResponse) {
        calls.append(.download(request: request))
        switch downloadReturnValue {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
    
    func upload(with request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        calls.append(.upload(request: request, from: bodyData))
        switch uploadReturnValue {
        case let .success(response):
            return response
        case let .failure(error):
            throw error
        }
    }
}

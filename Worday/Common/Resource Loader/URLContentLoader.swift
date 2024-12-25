import Foundation

protocol URLContentLoaderType {
    func content(of url: URL) throws -> Data
}

struct URLContentLoader: URLContentLoaderType {
    func content(of url: URL) throws -> Data {
        try .init(contentsOf: url)
    }
}


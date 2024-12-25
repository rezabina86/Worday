import Foundation

enum ResourceLoaderError: Error {
    case fileNotFound
}

protocol ResourceLoaderType {
    func loadResource(named name: String, withExtension ext: String) throws -> Data
}

struct ResourceLoader: ResourceLoaderType {
    
    init(bundle: BundleType,
         urlContentLoader: URLContentLoaderType) {
        self.bundle = bundle
        self.urlContentLoader = urlContentLoader
    }
    
    func loadResource(named name: String, withExtension ext: String) throws -> Data {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw ResourceLoaderError.fileNotFound
        }
        return try urlContentLoader.content(of: url)
    }
    
    // MARK: - Privates
    private let bundle: BundleType
    private let urlContentLoader: URLContentLoaderType
}

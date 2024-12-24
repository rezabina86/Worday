import Foundation

enum ResourceLoaderError: Error {
    case fileNotFound
}

protocol ResourceLoaderType {
    func loadResource(named name: String, withExtension ext: String) throws -> Data
}

struct ResourceLoader: ResourceLoaderType {
    
    init(bundle: BundleType) {
        self.bundle = bundle
    }
    
    func loadResource(named name: String, withExtension ext: String) throws -> Data {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw ResourceLoaderError.fileNotFound
        }
        return try Data(contentsOf: url)
    }
    
    // MARK: - Privates
    private let bundle: BundleType
}

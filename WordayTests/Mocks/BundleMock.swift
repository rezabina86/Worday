import Foundation
@testable import Worday

final class BundleMock: BundleType {
    
    public enum Call: Equatable {
        case path(forResource: String?, ofType: String?)
        case url(forResource: String?, withExtension: String?)
    }
    
    var preferredLocalizations: [String] = ["localeIdentifier"]
    
    func path(forResource name: String?, ofType ext: String?) -> String? {
        calls.append(.path(forResource: name, ofType: ext))
        return pathForResourceReturn
    }
    
    func url(forResource name: String?, withExtension ext: String?) -> URL? {
        calls.append(.url(forResource: name, withExtension: ext))
        return urlForResourceReturn
    }
    
    var infoDictionary: [String : Any]? = [:]
    var version: String? = "0.0.1"
    var build: String? = "1"
    var bundleIdentifier: String? = "com.worday.app"
    
    var calls: [Call] = []
    
    var pathForResourceReturn: String?
    var urlForResourceReturn: URL?
}

import Foundation

public protocol BundleType {
    func path(forResource name: String?, ofType ext: String?) -> String?
    func url(forResource name: String?, withExtension ext: String?) -> URL?

    var infoDictionary: [String: Any]? { get }

    var version: String? { get }
    var build: String? { get }

    var bundleIdentifier: String? { get }
}

public extension BundleType {
    var versionDescription: String? {
        guard let version = version else { return nil }

        if let build = build {
            return "\(version) (\(build))"
        } else {
            return "\(version)"
        }
    }
}

extension Bundle: BundleType {
    public var version: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    public var build: String? {
        return infoDictionary?[kCFBundleVersionKey as String] as? String
    }
}

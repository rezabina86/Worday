import Foundation

public func injectDependencies(into container: ContainerType) {
    container.register { _ -> ResourceLoaderType in
        ResourceLoader(bundle: Bundle.main)
    }
    
    container.register { container -> WordServiceType in
        WordService(resourceLoader: container.resolve())
    }
}

import Foundation

/// The composition root. A thin aggregator — each area owns its own registrations in a
/// `<Area>Dependencies.swift` extension on `ContainerType`. Add a new area by adding its file and one
/// line here, and add every new registration to `DependencyGraphTests`.
public func injectDependencies(into container: ContainerType) {
    container.registerCommonDependencies()
    container.registerAPIClientDependencies()
    container.registerDictionaryDependencies()
    container.registerWordDependencies()
    container.registerViewDependencies()
}

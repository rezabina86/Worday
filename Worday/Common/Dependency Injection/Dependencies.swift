import Foundation

/// The composition root. A thin aggregator — each feature owns its own registrations in a
/// `<Feature>Dependencies.swift` extension on `ContainerType`, co-located with the types it wires. Add a
/// new feature by adding its file and one line here, and add every new registration to
/// `DependencyGraphTests`.
public func injectDependencies(into container: ContainerType) {
    // Cross-cutting seams + persistence
    container.registerCommonDependencies()
    container.registerStorageDependencies()

    // Routing
    container.registerNavigationRoutingDependencies()
    container.registerModalRoutingDependencies()
    container.registerAlertRoutingDependencies()

    // Offline dictionary domain (word pool, validity, meanings — all served by WordDatabase)
    container.registerDictionaryDependencies()

    // Application use cases
    container.registerUseCasesDependencies()

    // Screens
    container.registerGameDependencies()
    container.registerOngoingGameDependencies()
    container.registerFinishedGameDependencies()
    container.registerWordMeaningDependencies()
    container.registerWordListDependencies()
    container.registerInfoModalDependencies()
}

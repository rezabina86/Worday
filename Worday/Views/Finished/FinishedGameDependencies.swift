import Foundation

extension ContainerType {
    /// The finished-game screen's view-model factory.
    func registerFinishedGameDependencies() {
        register { container in
            FinishedGameViewModelFactory(dictionaryUseCase: container.resolve(),
                                         streakUseCase: container.resolve(),
                                         attemptTrackerUseCase: container.resolve(),
                                         navigationRouter: container.resolve(),
                                         alertRouter: container.resolve())
            as FinishedGameViewModelFactoryType
        }
    }
}

import Foundation

extension ContainerType {
    /// The ongoing-game screen's view-model factory.
    func registerOngoingGameDependencies() {
        register { container in
            OngoingGameViewModelFactory(wordProviderUseCase: container.resolve(),
                                        arrayShuffle: container.resolve(),
                                        modalRouter: container.resolve(),
                                        attemptTrackerUseCase: container.resolve())
            as OngoingGameViewModelFactoryType
        }
    }
}

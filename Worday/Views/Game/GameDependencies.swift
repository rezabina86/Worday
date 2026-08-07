import Foundation

extension ContainerType {
    /// The root game screen's view-model factory.
    func registerGameDependencies() {
        register { container in
            GameViewModelFactory(fetchWordUseCase: container.resolve(),
                                 ongoingGameViewModelFactory: container.resolve(),
                                 finishedGameViewModelFactory: container.resolve(),
                                 finishGameRelay: container.resolve(),
                                 alertRouter: container.resolve())
            as GameViewModelFactoryType
        }
    }
}

import Foundation

extension ContainerType {
    /// The word-meaning screen's view-model factory.
    func registerWordMeaningDependencies() {
        register { container in
            WordMeaningViewModelFactory(dictionaryUseCase: container.resolve(),
                                        alertRouter: container.resolve())
            as WordMeaningViewModelFactoryType
        }
    }
}

import Foundation

extension ContainerType {
    /// The screen-level view-model factories and view-state converters.
    func registerViewDependencies() {
        register { container in
            GameViewModelFactory(fetchWordUseCase: container.resolve(),
                                 ongoingGameViewModelFactory: container.resolve(),
                                 finishedGameViewModelFactory: container.resolve(),
                                 finishGameRelay: container.resolve(),
                                 modalCoordinator: container.resolve(),
                                 navigationRouter: container.resolve())
            as GameViewModelFactoryType
        }

        register { container in
            OngoingGameViewModelFactory(wordProviderUseCase: container.resolve(),
                                        arrayShuffle: container.resolve(),
                                        modalCoordinator: container.resolve(),
                                        attemptTrackerUseCase: container.resolve(),
                                        infoModalViewStateConverter: container.resolve())
            as OngoingGameViewModelFactoryType
        }

        register { container in
            FinishedGameViewModelFactory(dictionaryUseCase: container.resolve(),
                                         streakUseCase: container.resolve(),
                                         attemptTrackerUseCase: container.resolve(),
                                         wordListViewStateConverter: container.resolve(),
                                         navigationRouter: container.resolve())
            as FinishedGameViewModelFactoryType
        }

        register { container in
            WordMeaningViewModelFactory(dictionaryUseCase: container.resolve())
            as WordMeaningViewModelFactoryType
        }

        register { container in
            WordListViewStateConverter(wordContext: container.resolve(),
                                       wordMeaningViewModelFactory: container.resolve(),
                                       navigationRouter: container.resolve())
            as WordListViewStateConverterType
        }

        register { _ in InfoModalViewStateConverter(bundle: Bundle.main) as InfoModalViewStateConverterType }
    }
}

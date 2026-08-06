import Foundation

extension ContainerType {
    /// The screen-level view-model factories, view-state converters, and the routing view-providers
    /// that map destinations to their screens.
    func registerViewDependencies() {
        register { container in
            GameViewModelFactory(fetchWordUseCase: container.resolve(),
                                 ongoingGameViewModelFactory: container.resolve(),
                                 finishedGameViewModelFactory: container.resolve(),
                                 finishGameRelay: container.resolve())
            as GameViewModelFactoryType
        }

        register { container in
            OngoingGameViewModelFactory(wordProviderUseCase: container.resolve(),
                                        arrayShuffle: container.resolve(),
                                        modalRouter: container.resolve(),
                                        attemptTrackerUseCase: container.resolve())
            as OngoingGameViewModelFactoryType
        }

        register { container in
            FinishedGameViewModelFactory(dictionaryUseCase: container.resolve(),
                                         streakUseCase: container.resolve(),
                                         attemptTrackerUseCase: container.resolve(),
                                         navigationRouter: container.resolve())
            as FinishedGameViewModelFactoryType
        }

        register { container in
            WordMeaningViewModelFactory(dictionaryUseCase: container.resolve())
            as WordMeaningViewModelFactoryType
        }

        register { container in
            WordListViewStateConverter(playedWordsLibrary: container.resolve(),
                                       navigationRouter: container.resolve())
            as WordListViewStateConverterType
        }

        register { _ in InfoModalViewStateConverter(bundle: Bundle.main) as InfoModalViewStateConverterType }

        register { container in
            NavigationDestinationViewProvider(wordListViewStateConverter: container.resolve(),
                                              wordMeaningViewModelFactory: container.resolve())
            as NavigationDestinationViewProviderType
        }

        register { container in
            ModalDestinationViewProvider(infoModalViewStateConverter: container.resolve())
            as ModalDestinationViewProviderType
        }
    }
}

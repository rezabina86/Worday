import Foundation
import SwiftData

public func injectDependencies(into container: ContainerType) {
    container.register { _ -> ResourceLoaderType in
        ResourceLoader(bundle: Bundle.main,
                       urlContentLoader: container.resolve())
    }
    
    container.register { container -> WordServiceType in
        WordService(resourceLoader: container.resolve())
    }
    
    container.register { container -> WordRepositoryType in
        WordRepository(wordService: container.resolve())
    }
    
    container.register { _ -> URLContentLoaderType in
        URLContentLoader()
    }
    
    container.register { _ -> WordStorageModelContextType in
        ModelContext(sharedModelContainer)
    }
    
    container.register { _ -> DateServiceType in
        DateService()
    }
    
    container.register { _ -> UUIDProviderType in
        UUIDProvider()
    }
    
    container.register { container -> WordProviderUseCaseType in
        WordProviderUseCase(wordRepository: container.resolve(),
                            wordContext: container.resolve(),
                            randomWordProducer: container.resolve(),
                            dateService: container.resolve(),
                            userSettings: container.resolve(),
                            uuidProvider: container.resolve(),
                            dateProvider: Date(),
                            finishGameRelay: container.resolve(),
                            attemptTrackerUseCase: container.resolve())
    }
    
    container.register { _ -> RandomWordProducerType in
        RandomWordProducer()
    }
    
    container.register { container -> GameViewModelFactoryType in
        GameViewModelFactory(fetchWordUseCase: container.resolve(),
                             ongoingGameViewModelFactory: container.resolve(),
                             finishedGameViewModelFactory: container.resolve(),
                             scenePhaseObserver: container.resolve(),
                             appTriggerFactory: container.resolve(),
                             modalCoordinator: container.resolve(),
                             navigationRouter: container.resolve())
    }
    
    container.register { container -> UserSettingsType in
        UserSettings(userDefaults: container.resolve())
    }
    
    container.register { _ -> UserDefaultsType in
        UserDefaults.standard
    }
    
    container.register { container -> OngoingGameViewModelFactoryType in
        OngoingGameViewModelFactory(wordProviderUseCase: container.resolve(),
                                    arrayShuffle: container.resolve(),
                                    modalCoordinator: container.resolve(),
                                    attemptTrackerUseCase: container.resolve(),
                                    infoModalViewStateConverter: container.resolve())
    }
    
    container.register { _ -> InfoModalViewStateConverterType in
        InfoModalViewStateConverter(bundle: Bundle.main)
    }
    
    container.register { _ -> ArrayShuffleType in
        ArrayShuffle()
    }
    
    container.register(in: .weakContainer) { container -> AppTriggerFactoryType in
        AppTriggerFactory(scenePhaseObserver: container.resolve(),
                          finishGameRelay: container.resolve())
    }
    
    container.register(in: .weakContainer) { _ -> ScenePhaseObserverType in
        ScenePhaseObserver()
    }
    
    container.register(in: .weakContainer) { _ -> FinishGameRelayType in
        FinishGameRelay()
    }
    
    container.register(in: .container) { container -> HTTPClientType in
        HTTPClient(sessionFactory: container.resolve(),
                   extendedCache: true)
    }
    
    container.register { _ -> URLSessionFactoryType in
        URLSessionFactory()
    }
    
    container.register { container -> DictionaryServiceType in
        DictionaryService(client: container.resolve())
    }
    
    container.register { container -> DictionaryRepositoryType in
        DictionaryRepository(dictionaryService: container.resolve())
    }
    
    container.register { container -> DictionaryUseCaseType in
        DictionaryUseCase(dictionaryRepository: container.resolve())
    }
    
    container.register { container -> FinishedGameViewModelFactoryType in
        FinishedGameViewModelFactory(dictionaryUseCase: container.resolve(),
                                     streakUseCase: container.resolve(),
                                     attemptTrackerUseCase: container.resolve(),
                                     wordListViewStateConverter: container.resolve(),
                                     navigationRouter: container.resolve())
    }
    
    container.register(in: .weakContainer) { container -> ModalCoordinatorType in
        ModalCoordinator()
    }
    
    container.register { _ -> CalendarServiceType in
        Calendar.current
    }
    
    container.register { container -> StreakUseCaseType in
        StreakUseCase(wordContext: container.resolve(),
                      calendarService: container.resolve())
    }
    
    container.register(in: .weakContainer) { container -> AttemptTrackerUseCaseType in
        AttemptTrackerUseCase(userSettings: container.resolve())
    }
    
    container.register(in: .weakContainer) { _ -> NavigationRouterType in
        NavigationRouter()
    }
    
    container.register { container -> WordListViewStateConverterType in
        WordListViewStateConverter(wordContext: container.resolve())
    }
}

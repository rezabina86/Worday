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
    
    container.register { container -> FetchWordUseCaseType in
        FetchWordUseCase(wordRepository: container.resolve(),
                         wordContext: container.resolve(),
                         randomWordProducer: container.resolve(),
                         dateService: container.resolve(),
                         userSettings: container.resolve())
    }
    
    container.register { _ -> RandomWordProducerType in
        RandomWordProducer()
    }
    
    container.register { container -> GameViewModelFactoryType in
        GameViewModelFactory(fetchWordUseCase: container.resolve())
    }
    
    container.register { container -> UserSettingsType in
        UserSettings(userDefaults: container.resolve())
    }
    
    container.register { _ -> UserDefaultsType in
        UserDefaults.standard
    }
}

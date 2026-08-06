import Foundation

extension ContainerType {
    func registerWordDependencies() {
        register { container in WordService(resourceLoader: container.resolve()) as WordServiceType }

        register { container in WordRepository(wordService: container.resolve()) as WordRepositoryType }

        register { container in
            WordProviderUseCase(wordRepository: container.resolve(),
                                wordContext: container.resolve(),
                                randomWordProducer: container.resolve(),
                                dateService: container.resolve(),
                                userSettings: container.resolve(),
                                uuidProvider: container.resolve(),
                                dateProvider: Date(),
                                finishGameRelay: container.resolve(),
                                attemptTrackerUseCase: container.resolve())
            as WordProviderUseCaseType
        }

        register { container in
            StreakUseCase(wordContext: container.resolve(),
                          calendarService: container.resolve())
            as StreakUseCaseType
        }
    }
}

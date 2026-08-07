import Foundation

extension ContainerType {
    /// The application use cases and the word-provider data pipeline (service → repository → provider)
    /// they build on. The pipeline's types span layers (`Common/Services`, `Repositories`, `Use Cases`)
    /// but form one vertical feature, so their wiring is co-located here with the use case they serve.
    func registerUseCasesDependencies() {
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
                                attemptTrackerUseCase: container.resolve(),
                                playedWordsLibrary: container.resolve())
            as WordProviderUseCaseType
        }

        register { container in
            StreakUseCase(playedWordsLibrary: container.resolve(),
                          calendarService: container.resolve())
            as StreakUseCaseType
        }

        register(in: .container) { container in
            AttemptTrackerUseCase(userSettings: container.resolve()) as AttemptTrackerUseCaseType
        }
    }
}

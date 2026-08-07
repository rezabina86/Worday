import Foundation

extension ContainerType {
    /// The application use cases and the word-provider pipeline they build on. The daily-word pool is
    /// served by the offline `WordDatabase` (a cross-cutting seam registered in `registerCommonDependencies`),
    /// so this file wires only the use cases themselves.
    func registerUseCasesDependencies() {
        register { container in
            WordProviderUseCase(wordDatabase: container.resolve(),
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

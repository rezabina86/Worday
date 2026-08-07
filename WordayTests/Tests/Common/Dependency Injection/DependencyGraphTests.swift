import Testing
@testable import Worday

/// Resolves every type registered by `injectDependencies(into:)` from a fully-wired container, so the
/// composition root can never silently break: a missing registration `fatalError`s on `resolve`, and a
/// broken constructor throws at build/resolve time. Add every new DI registration here.
struct DependencyGraphTests {

    // MARK: - Publics

    @Test("it resolves every registered dependency")
    func resolvesEveryDependency() {
        let container = makeWiredContainer()

        _ = container.resolve() as ResourceLoaderType
        _ = container.resolve() as DecoderType
        _ = container.resolve() as WordDatabaseType
        _ = container.resolve() as URLContentLoaderType
        _ = container.resolve() as WordStorageModelContextType
        _ = container.resolve() as DateServiceType
        _ = container.resolve() as UUIDProviderType
        _ = container.resolve() as WordProviderUseCaseType
        _ = container.resolve() as RandomWordProducerType
        _ = container.resolve() as GameViewModelFactoryType
        _ = container.resolve() as UserSettingsType
        _ = container.resolve() as UserDefaultsType
        _ = container.resolve() as OngoingGameViewModelFactoryType
        _ = container.resolve() as InfoModalViewStateConverterType
        _ = container.resolve() as ArrayShuffleType
        _ = container.resolve() as FinishGameRelayType
        _ = container.resolve() as DictionaryRepositoryType
        _ = container.resolve() as DictionaryUseCaseType
        _ = container.resolve() as FinishedGameViewModelFactoryType
        _ = container.resolve() as ModalRouterType
        _ = container.resolve() as CalendarServiceType
        _ = container.resolve() as StreakUseCaseType
        _ = container.resolve() as AttemptTrackerUseCaseType
        _ = container.resolve() as NavigationRouterType
        _ = container.resolve() as WordListViewStateConverterType
        _ = container.resolve() as WordMeaningViewModelFactoryType
        _ = container.resolve() as NavigationDestinationViewProviderType
        _ = container.resolve() as ModalDestinationViewProviderType
        _ = container.resolve() as PlayedWordsLibraryType
        _ = container.resolve() as AlertRouterType
    }

    @Test("the shared word database resolves to the same instance")
    func wordDatabaseIsShared() {
        let container = makeWiredContainer()

        let first = container.resolve() as WordDatabaseType
        let second = container.resolve() as WordDatabaseType

        #expect(first === second)
    }

    @Test("the shared played-words library resolves to the same instance")
    func playedWordsLibraryIsShared() {
        let container = makeWiredContainer()

        let first = container.resolve() as PlayedWordsLibraryType
        let second = container.resolve() as PlayedWordsLibraryType

        #expect(first === second)
    }

    @Test("the shared model context resolves to the same instance")
    func modelContextIsShared() {
        let container = makeWiredContainer()

        let first = container.resolve() as WordStorageModelContextType
        let second = container.resolve() as WordStorageModelContextType

        #expect(first === second)
    }

    // MARK: - Privates

    private func makeWiredContainer() -> ContainerType {
        let container = Container()
        injectDependencies(into: container)
        return container
    }
}

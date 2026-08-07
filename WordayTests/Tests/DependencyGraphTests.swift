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
        _ = container.resolve() as WordServiceType
        _ = container.resolve() as WordRepositoryType
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
        _ = container.resolve() as HTTPClientType
        _ = container.resolve() as URLSessionFactoryType
        _ = container.resolve() as DictionaryServiceType
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

    @Test("a .container-scoped dependency resolves to the same instance")
    func containerScopeReturnsSameInstance() {
        let container = makeWiredContainer()

        let first = container.resolve() as HTTPClientType
        let second = container.resolve() as HTTPClientType

        #expect(first === second)
    }

    @Test("the shared played-words library resolves to the same instance")
    func playedWordsLibraryIsShared() {
        let container = makeWiredContainer()

        let first = container.resolve() as PlayedWordsLibraryType
        let second = container.resolve() as PlayedWordsLibraryType

        #expect(first === second)
    }

    // MARK: - Privates

    private func makeWiredContainer() -> ContainerType {
        let container = Container()
        injectDependencies(into: container)
        return container
    }
}

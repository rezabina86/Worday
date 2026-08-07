import Foundation

extension ContainerType {
    /// Cross-cutting system seams (bundle-backed loaders, the clock, user settings) and the app-wide
    /// `FinishGameRelay` event bus. Feature-owned registrations live next to their feature: routing under
    /// `Routing/`, persistence under `Storage/`, use cases under `Use Cases/`, screens under
    /// `Views/<Screen>/`.
    func registerCommonDependencies() {
        register { container in
            ResourceLoader(bundle: Bundle.main,
                           urlContentLoader: container.resolve())
            as ResourceLoaderType
        }

        register { _ in URLContentLoader() as URLContentLoaderType }

        register { _ in JSONDecoder() as DecoderType }

        register(in: .container) { container in
            WordDatabase(resourceLoader: container.resolve(),
                         decoder: container.resolve())
            as WordDatabaseType
        }

        register { _ in DateService() as DateServiceType }

        register { _ in UUIDProvider() as UUIDProviderType }

        register { _ in RandomWordProducer() as RandomWordProducerType }

        register { _ in ArrayShuffle() as ArrayShuffleType }

        register { _ in Calendar.current as CalendarServiceType }

        register { container in UserSettings(userDefaults: container.resolve()) as UserSettingsType }

        register { _ in UserDefaults.standard as UserDefaultsType }

        register(in: .container) { _ in FinishGameRelay() as FinishGameRelayType }
    }
}

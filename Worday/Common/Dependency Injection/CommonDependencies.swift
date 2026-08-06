import Foundation
import SwiftData

extension ContainerType {
    /// Cross-cutting system seams (codecs, clock, storage, bundle-backed loaders) and the shared
    /// `.container`-scoped `@Observable` holders whose identity must survive view/view-model churn.
    func registerCommonDependencies() {
        register { container in
            ResourceLoader(bundle: Bundle.main,
                           urlContentLoader: container.resolve())
            as ResourceLoaderType
        }

        register { _ in URLContentLoader() as URLContentLoaderType }

        register { _ in ModelContext(sharedModelContainer) as WordStorageModelContextType }

        register { _ in DateService() as DateServiceType }

        register { _ in UUIDProvider() as UUIDProviderType }

        register { _ in RandomWordProducer() as RandomWordProducerType }

        register { _ in ArrayShuffle() as ArrayShuffleType }

        register { _ in Calendar.current as CalendarServiceType }

        register { container in UserSettings(userDefaults: container.resolve()) as UserSettingsType }

        register { _ in UserDefaults.standard as UserDefaultsType }

        register(in: .container) { _ in NavigationRouter() as NavigationRouterType }

        register(in: .container) { _ in ModalRouter() as ModalRouterType }

        register(in: .container) { _ in FinishGameRelay() as FinishGameRelayType }

        register(in: .container) { container in
            AttemptTrackerUseCase(userSettings: container.resolve()) as AttemptTrackerUseCaseType
        }
    }
}

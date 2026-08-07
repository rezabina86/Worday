import SwiftUI

@main
struct WordayApp: App {

    // MARK: - Life Cycle

    init(container: ContainerType) {
        self.container = container
        configureDependencies(container)

        self.gameViewModelFactory = container.resolve()
        self.navigationRouter = container.resolve()
        self.navigationDestinationViewProvider = container.resolve()
        self.modalRouter = container.resolve()
        self.modalDestinationViewProvider = container.resolve()
        self.alertRouter = container.resolve()

        // Hydrate the shared played-words projection once at launch; writers reload() it thereafter.
        let playedWordsLibrary: PlayedWordsLibraryType = container.resolve()
        playedWordsLibrary.load()
    }

    init() {
        self.init(container: Container())
    }

    // MARK: - Publics

    var body: some Scene {
        WindowGroup {
            GameView(viewModel: gameViewModelFactory.make())
                .navigationHost(router: navigationRouter, provider: navigationDestinationViewProvider)
                .modalHost(router: modalRouter, provider: modalDestinationViewProvider)
                .alertHost(router: alertRouter)
        }
    }

    // MARK: - Privates

    private let container: ContainerType
    private var configureDependencies = injectDependencies

    private let gameViewModelFactory: GameViewModelFactoryType
    private let navigationRouter: NavigationRouterType
    private let navigationDestinationViewProvider: NavigationDestinationViewProviderType
    private let modalRouter: ModalRouterType
    private let modalDestinationViewProvider: ModalDestinationViewProviderType
    private let alertRouter: AlertRouterType
}

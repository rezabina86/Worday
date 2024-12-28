import SwiftUI

@main
struct WordayApp: App {
    
    init(container: ContainerType) {
        self.container = container
        configureDependencies(container)
        
        self.gameViewModelFactory = container.resolve()
    }
    
    init() {
        self.init(container: Container())
    }
    
    var body: some Scene {
        WindowGroup {
            GameView(viewModel: gameViewModelFactory.create())
        }
    }
    
    // MARK: - Privates
    private let container: ContainerType
    private var configureDependencies = injectDependencies
    
    private let gameViewModelFactory: GameViewModelFactoryType
}

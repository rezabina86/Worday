import SwiftUI
import Combine

struct GameView: View {
    
    init(viewModel: GameViewModelType) {
        self.viewModel = viewModel
        
        viewModel.currentNavigationPath
            .receive(on: RunLoop.main)
            .assign(to: \.currentNavigationPath, on: self)
            .store(in: &subscriptions)
    }
    
    var body: some View {
        NavigationStack(
            path: .init(
                get: {
                    return currentNavigationPath
                },
                set: {
                    viewModel.setNavigationCurrentPath($0)
                }
            )
        ) {
            view(for: viewState)
                .navigationDestination(
                    for: NavigationDestination.self
                ) { route in
                    destination(for: route)
                }
                .navigationBarHidden(true)
        }
        .task {
            for await vs in viewModel.viewState.values {
                withAnimation {
                    self.viewState = vs
                }
            }
        }
        .task {
            for await destination in viewModel.currentDestination.values {
                self.currentModalDestination = destination
            }
        }
        .onChange(of: scenePhase) { old, new in
            viewModel.scenePhaseChanged(new)
        }
        .sheet(item: .init(get: {
            self.currentModalDestination
        }, set: { destination in
            viewModel.setModalDestination(destination)
        })) { destination in
            switch currentModalDestination {
            case let .info(viewState):
                InfoModalView(viewState: viewState)
            case nil:
                EmptyView()
            }
        }
    }
    
    // MARK: - Privates
    private let viewModel: GameViewModelType
    private var subscriptions: Set<AnyCancellable> = []
    
    @State private var viewState: GameViewState = .empty
    @State private var currentModalDestination: ModalCoordinatorDestination?
    @ObservedState private var currentNavigationPath: NavigationPath = .init()
    @Environment(\.scenePhase) private var scenePhase
    
    
    // MARK: - View Builders
    @ViewBuilder
    private func view(for viewState: GameViewState) -> some View {
        switch viewState {
        case .empty:
            EmptyStateView()
                .transition(.opacity)
                .animation(.easeInOut(duration: 1.5), value: viewState)
        case .error:
            Text("Seomething horrible happened.\nPlease delete and re-install the app")
                .font(bodyFont)
                .transition(.opacity)
                .padding(.space_16pt)
        case let .noWordToday(viewModel):
            FinishedGameView(viewModel: viewModel)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: viewState)
        case let .game(viewModel):
            OngoingGameView(viewModel: viewModel)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: viewState)
        }
    }
}

private extension View {
    @ViewBuilder
    func destination(for destination: NavigationDestination) -> some View {
        switch destination {
        case let .wordList(viewState):
            WordListView(viewState: viewState)
        case let .wordMeaning(viewModel):
            WordMeaningView(viewModel: viewModel)
        case .none:
            EmptyView()
        }
    }
}

enum GameViewState: Equatable {
    case empty
    case error
    case noWordToday(viewModel: FinishedGameViewModelType)
    case game(viewModel: OngoingGameViewModelType)
    
    var id: String {
        switch self {
        case .empty: return "empty"
        case .error: return "error"
        case let .noWordToday(viewModel): return String(describing: viewModel.self)
        case let .game(viewModel): return String(describing: viewModel.self)
        }
    }
    
    static func == (lhs: GameViewState, rhs: GameViewState) -> Bool {
        lhs.id == rhs.id
    }
}

import SwiftUI

struct GameView: View {

    // MARK: - Life Cycle

    init(viewModel: GameViewModelType) {
        self.viewModel = viewModel
    }

    // MARK: - Publics

    var body: some View {
        NavigationStack(
            path: Binding(
                get: { viewModel.navigationPath },
                set: { viewModel.navigationPath = $0 }
            )
        ) {
            ZStack {
                WDBackground()
                view(for: viewModel.viewState)
            }
            .navigationDestination(for: NavigationDestination.self) { route in
                destination(for: route)
            }
            .navigationBarHidden(true)
        }
        .task {
            viewModel.refresh()
            await viewModel.observeGameFinished()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                viewModel.refresh()
            }
        }
        .sheet(item: Binding(
            get: { viewModel.modalDestination },
            set: { viewModel.modalDestination = $0 }
        )) { destination in
            switch destination {
            case let .info(viewState):
                InfoModalView(viewState: viewState)
            }
        }
    }

    // MARK: - Privates

    private let viewModel: GameViewModelType

    @Environment(\.scenePhase) private var scenePhase

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
        case let .noWordToday(viewModel): return ObjectIdentifier(viewModel).debugDescription
        case let .game(viewModel): return ObjectIdentifier(viewModel).debugDescription
        }
    }

    static func == (lhs: GameViewState, rhs: GameViewState) -> Bool {
        lhs.id == rhs.id
    }
}

import SwiftUI

struct GameView: View {

    // MARK: - Life Cycle

    init(viewModel: GameViewModelType) {
        self.viewModel = viewModel
    }

    // MARK: - Publics

    var body: some View {
        ZStack {
            WDBackground()
            view(for: viewModel.viewState)
        }
        .navigationBarHidden(true)
        .task {
            viewModel.refresh()
            await viewModel.observeGameFinished()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                viewModel.refresh()
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

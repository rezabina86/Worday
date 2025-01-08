import SwiftUI

struct GameView: View {
    
    init(viewModel: GameViewModelType) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        view(for: viewState)
        .task {
            for await vs in viewModel.viewState.values {
                withAnimation {
                    self.viewState = vs
                }
            }
        }
        .onChange(of: scenePhase) { old, new in
            viewModel.scenePhaseChanged(new)
        }
    }
    
    // MARK: - Privates
    private let viewModel: GameViewModelType
    
    @State private var viewState: GameViewState = .empty
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
            Text("Seomething horrible happened.\nPlease try delete and re-install the app")
                .font(wdFont16)
                .transition(.opacity)
        case let .noWordToday(viewState):
            FinishedGameView(viewState: viewState)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: viewState)
        case let .game(viewState):
            OngoingGameView(viewState: viewState)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: viewState)
        }
    }
}

enum GameViewState: Equatable {
    case empty
    case error
    case noWordToday(viewState: FinishedGameViewState)
    case game(viewState: OngoingGameViewState)
}

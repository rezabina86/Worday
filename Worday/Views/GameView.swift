import SwiftUI

struct GameView: View {
    
    init(viewModel: GameViewModelType) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        view(for: viewState)
        .task {
            for await vs in viewModel.viewState.values {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.viewState = vs
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
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
        case .empty: EmptyView()
        case .error:
            Text("Error")
                .transition(.opacity)
        case let .noWordToday(viewState):
            FinishedGameView(viewState: viewState)
                .transition(.opacity)
        case let .game(viewState):
            OngoingGameView(viewState: viewState)
                .transition(.opacity)
        }
    }
}

enum GameViewState: Equatable {
    case empty
    case error
    case noWordToday(viewState: FinishedGameViewState)
    case game(viewState: OngoingGameViewState)
}

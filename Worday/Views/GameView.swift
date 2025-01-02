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
    }
    
    // MARK: - Privates
    private let viewModel: GameViewModelType
    
    @State private var viewState: GameViewState = .error
    
    // MARK: - View Builders
    @ViewBuilder
    private func view(for viewState: GameViewState) -> some View {
        switch viewState {
        case .error:
            Text("Error")
                .transition(.opacity)
        case let .noWordToday(lastWord):
            Text("You have completed all words today\nLast word: \(lastWord)")
                .transition(.opacity)
        case let .game(viewState):
            OngoingGameView(viewState: viewState)
                .transition(.opacity)
        }
    }
}

enum GameViewState: Equatable {
    case error
    case noWordToday(lastWord: String)
    case game(viewState: OngoingGameViewState)
}

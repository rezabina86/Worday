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
        case let .noWordToday(lastWord):
            Text("You have completed all words today\nLast word: \(lastWord)")
        case let .game(viewState):
            OngoingGameView(viewState: viewState)
        }
    }
}

enum GameViewState: Equatable {
    case error
    case noWordToday(lastWord: String)
    case game(viewState: OngoingGameViewState)
}

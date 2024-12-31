import SwiftUI

struct OngoingGameView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: .size_128pt)
            
            GeometryReader { proxy in
                buildRowsView(from: viewState, proxy: proxy)
            }.padding(.space_48pt)
            
            Spacer()
            
            KeyBoardView(viewState: viewState.keyboardViewState)
            
            Spacer()
                .frame(height: .size_128pt)
        }
    }
    
    // MARK: - Privates
    @State private var viewState: GameViewState.OngoingGameViewState = .empty
    
    // MARK: - Sub views
    @ViewBuilder
    func buildRowsView(from viewState: GameViewState.OngoingGameViewState,
                       proxy: GeometryProxy) -> some View {
        let availableWidth = proxy.size.width - (5 * (Constant.numberOfCharacters - 1).cgFloatValue)
        let size = availableWidth / Constant.numberOfCharacters.cgFloatValue
        HStack(spacing: .space_8pt) {
            ForEach(viewState.characters) { char in
                CharacterCellView(
                    character: char,
                    width: size,
                    height: size
                )
            }
        }
    }
}



extension GameViewState {
    struct OngoingGameViewState: Equatable {
        let characters: [Character]
        let keyboardViewState: KeyBoardViewState
    }
}

extension GameViewState.OngoingGameViewState {
    struct Character: Equatable, Identifiable {
        let char: String
        let state: State
        let id: String
        
        enum State: Equatable {
            case draft
            case correct
            case misplaced
        }
    }
}

extension GameViewState.OngoingGameViewState {
    static let empty: Self = .init(
        characters: [.init(char: "", state: .draft, id: "a"),
                     .init(char: "B", state: .draft, id: "b"),
                     .init(char: "C", state: .misplaced, id: "c"),
                     .init(char: "D", state: .correct, id: "d"),
                     .init(char: "E", state: .correct, id: "e")],
        keyboardViewState: .empty
    )
}

#Preview {
    OngoingGameView()
}

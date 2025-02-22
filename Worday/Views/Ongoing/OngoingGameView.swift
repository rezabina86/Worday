import SwiftUI

struct OngoingGameView: View {
    
    init(viewModel: OngoingGameViewModelType) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Button {
                        viewState.onTapInfoButton.action()
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .resizable()
                            .frame(width: .size_24pt, height: .size_24pt)
                            .foregroundStyle(.text)
                            .contentShape(Rectangle())
                    }
                }

                HStack {
                    Image("logo")
                        .resizable()
                        .frame(width: .size_24pt, height: .size_24pt)
                    
                    Text("DailySort")
                        .font(bodyFont)
                        
                }
            }
            .padding([.horizontal], .space_48pt)

            Spacer()
                .frame(height: .size_128pt)
            
            viewState.numberOfTries.map { number in
                Group {
                    Text("Number of Tries: ")
                        .font(bodyFont)
                    +
                    Text("\(number)")
                        .font(bodyFont)
                        .foregroundStyle(Color.orange)
                }
                .animation(.easeInOut(duration: 0.5), value: viewState)
            }
            
            GeometryReader { proxy in
                buildRowsView(from: viewState, proxy: proxy)
            }.padding(.space_48pt)
            
            Spacer()
            
            KeyBoardView(viewState: viewState.keyboardViewState)
            
            Spacer()
                .frame(height: .size_128pt)
        }
        .task {
            for await vs in viewModel.viewState.values {
                withAnimation {
                    self.viewState = vs
                }
            }
        }
    }
    
    // MARK: - Privates
    private let viewModel: OngoingGameViewModelType
    @State private var viewState: GameViewState.OngoingGameViewState = .empty
    
    // MARK: - Sub views
    @ViewBuilder
    private func buildRowsView(from viewState: GameViewState.OngoingGameViewState,
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
        let numberOfTries: Int?
        let keyboardViewState: KeyBoardViewState
        let onTapInfoButton: UserAction
    }
}

extension GameViewState.OngoingGameViewState {
    struct Character: Equatable, Identifiable {
        let id: String
        let state: State
        
        var isEmpty: Bool {
            state == .empty
        }
        
        var character: String? {
            switch self.state {
            case .empty: return nil
            case let .correct(char): return char
            case let .draft(char): return char
            case let .misplaced(char): return char
            }
        }
        
        var isCorrect: Bool {
            switch self.state {
            case .draft, .empty, .misplaced: return false
            case .correct: return true
            }
        }
        
        var isDraft: Bool {
            switch self.state {
            case .correct, .misplaced, .empty: return false
            case .draft: return true
            }
        }
        
        enum State: Equatable {
            case empty
            case draft(char: String)
            case correct(char: String)
            case misplaced(char: String)
        }
    }
}

extension GameViewState.OngoingGameViewState.Character {
    static func empty(id: String) -> Self {
        .init(id: id, state: .empty)
    }
}

extension GameViewState.OngoingGameViewState {
    static let empty: Self = .init(
        characters: [
            .empty(id: "1"),
            .empty(id: "2"),
            .empty(id: "3"),
            .empty(id: "4"),
            .empty(id: "5")
        ],
        numberOfTries: nil,
        keyboardViewState: .empty,
        onTapInfoButton: .empty
    )
}

import SwiftUI

struct CharacterCellView: View {
    let character: GameViewState.OngoingGameViewState.Character
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        switch character.state {
        case .empty: buildCell(with: "")
        case let .correct(char): buildCell(with: char)
        case let .draft(char): buildCell(with: char)
        case let .misplaced(char): buildCell(with: char)
        }
    }
    
    @ViewBuilder
    private func buildCell(with char: String) -> some View {
        Text(String(char).uppercased())
            .font(wdFont)
            .fontWeight(.bold)
            .frame(width: width, height: height)
            .background(background)
            .cellBorderView(for: character)
            .cellForegroundColor(for: character)
            .transition(.opacity)
    }
    
    @ViewBuilder
    private var background: some View {
        switch character.state {
        case .correct: Color.correct
        case .misplaced: Color.misplaced
        case .draft: Color.backgroundColor
        case .empty: Color.backgroundColor
        }
    }
}

private extension View {
    @ViewBuilder
    func cellBorderView(for character: GameViewState.OngoingGameViewState.Character) -> some View {
        switch character.state {
        case .correct:
            self.cornerRadius(.radius_medium)
                .shadow(color: Color.green.opacity (0.9), radius: 5)
        case .misplaced:
            self.cornerRadius(.radius_medium)
                .shadow(color: Color.yellow.opacity (0.9), radius: 5)
        case .empty:
            self.overlay {
                RoundedRectangle(cornerRadius: .radius_medium)
                    .stroke(LinearGradient(
                        colors: [Color.borderInactiveColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing), lineWidth: .size_4pt)
            }
        case .draft:
            self.overlay {
                RoundedRectangle(cornerRadius: .radius_medium)
                    .stroke(LinearGradient(
                        colors: Array(repeating: [.yellow, .green], count: 4).flatMap { $0 },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing), lineWidth: .size_4pt)
                    .shadow(color: Color.teal.opacity (0.9), radius: 10)
            }
        }
    }
    
    @ViewBuilder
    func cellForegroundColor(for character: GameViewState.OngoingGameViewState.Character) -> some View {
        switch character.state {
        case .correct, .misplaced: self.foregroundColor(.white)
        case .draft, .empty: self.foregroundColor(Color.textColor)
        }
    }
}

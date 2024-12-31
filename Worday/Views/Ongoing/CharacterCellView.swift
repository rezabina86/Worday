import SwiftUI

struct CharacterCellView: View {
    let character: GameViewState.OngoingGameViewState.Character
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Text(String(character.char).uppercased())
            .font(wdFont)
            .fontWeight(.bold)
            .frame(width: width, height: height)
            .background(background)
            .cellBorderView(for: character)
            .cellForegroundColor(for: character)
    }
    
    @ViewBuilder
    private var background: some View {
        switch character.state {
        case .correct: Color.correct
        case .misplaced: Color.misplaced
        case .draft: Color.backgroundColor
        }
    }
}

private extension View {
    @ViewBuilder
    func cellBorderView(for character: GameViewState.OngoingGameViewState.Character) -> some View {
        switch character.state {
        case .correct, .misplaced: self
        case .draft:
            self.border(Color.borderInactiveColor, width: .size_4pt)
        }
    }
    
    @ViewBuilder
    func cellForegroundColor(for character: GameViewState.OngoingGameViewState.Character) -> some View {
        switch character.state {
        case .correct, .misplaced: self.foregroundColor(.white)
        case .draft: self.foregroundColor(Color.textColor)
        }
    }
}

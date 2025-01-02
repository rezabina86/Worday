import SwiftUI

struct FinishedGameView: View {
    
    let viewState: FinishedGameViewState
    
    var body: some View {
        VStack(alignment: .center, spacing: .space_20pt) {
            Text(viewState.title)
                .multilineTextAlignment(.center)
                .font(wdFont24)
            Text(viewState.message)
                .multilineTextAlignment(.center)
                .font(wdFont16)
            Text(viewState.subtitle)
                .multilineTextAlignment(.center)
                .font(wdFont16)
        }
        .padding(.space_64pt)
    }
}

struct FinishedGameViewState: Equatable {
    let title: String
    let message: String
    let subtitle: String
}

extension FinishedGameViewState {
    static let empty: Self = .init(title: "", message: "", subtitle: "")
}

#Preview {
    FinishedGameView(viewState: .init(
        title: "Great job!",
        message: "You’ve solved today’s puzzle. The word was ABCDE",
        subtitle: "Come back tomorrow for another challenge!"
    ))
}

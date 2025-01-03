import SwiftUI

struct FinishedGameView: View {
    
    let viewState: FinishedGameViewState
    
    var body: some View {
        VStack(alignment: .center, spacing: .space_20pt) {
            Text(viewState.title)
                .multilineTextAlignment(.center)
                .font(.title)
                .bold()
            
            buildMeaningSection(from: viewState.meaning)
            
            Text(viewState.subtitle)
                .multilineTextAlignment(.center)
                .font(.body)
                .bold()
        }
        .padding(.space_64pt)
    }
    
    @ViewBuilder
    func buildMeaningSection(from meaning: FinishedGameViewState.Meaning) -> some View {
        switch meaning {
        case .loading:
            ProgressView()
        case let .error(message):
            Text(message)
                .multilineTextAlignment(.center)
                .font(wdFont16)
        case let .meaning(viewState):
            buildMeaningView(from: viewState)
        }
    }
    
    @ViewBuilder
    func buildMeaningView(from viewState: FinishedGameViewState.Meaning.MeaningViewState) -> some View {
        VStack(spacing: .space_12pt) {
            Text(viewState.word)
                .multilineTextAlignment(.center)
                .font(wdFont24)
            ForEach(viewState.defination) { def in
                VStack(alignment: .center, spacing: .space_8pt) {
                    Text(def.type)
                        .multilineTextAlignment(.center)
                        .font(wdFont16)
                        .bold()
                    
                    Text(def.meaning)
                        .multilineTextAlignment(.center)
                        .font(wdFont16)
                }
            }
        }
    }
}

struct FinishedGameViewState: Equatable {
    let title: String
    let meaning: FinishedGameViewState.Meaning
    let subtitle: String
}

extension FinishedGameViewState {
    enum Meaning: Equatable {
        case loading
        case error(message: String)
        case meaning(viewState: MeaningViewState)
    }
}

extension FinishedGameViewState.Meaning {
    struct MeaningViewState: Equatable {
        let word: String
        let defination: [Definition]
    }
}

extension FinishedGameViewState.Meaning.MeaningViewState {
    struct Definition: Equatable, Identifiable {
        let id: UUID
        let type: String
        let meaning: String
    }
}

extension FinishedGameViewState {
    static let empty: Self = .init(title: "", meaning: .loading, subtitle: "")
}

#Preview {
//    FinishedGameView(viewState: .init(
//        title: "Great job!",
//        meaning: .error(message: "You’ve solved today’s puzzle. The word was ABCDE"),
//        subtitle: "Come back tomorrow for another challenge!"
//    ))
    FinishedGameView(viewState: .init(
        title: "Great job!",
        meaning: .meaning(viewState: .init(
            word: "ABCDE",
            defination: [
                .init(
                    id: .init(),
                    type: "noun",
                    meaning: "very special noun"
                ),
                .init(
                    id: .init(),
                    type: "verb",
                    meaning: "very special verb"
                )
            ]
        )),
        subtitle: "Come back tomorrow for another challenge!"
    ))
}

import SwiftUI

struct FinishedGameView: View {
    
    let viewState: FinishedGameViewState
    
    var body: some View {
        VStack(alignment: .center, spacing: .space_16pt) {
            Spacer()
                .frame(height: .space_12pt)
            
            Text(viewState.title)
                .multilineTextAlignment(.center)
                .font(titleFont2)
                .bold()
            
            HStack {
                VStack {
                    Text("\(viewState.totalPlayed.value)")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .bold()
                        .foregroundStyle(Color.orange)
                    Text(viewState.totalPlayed.title)
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .bold()
                }
                Spacer()
                    .frame(width: .space_24pt)
                VStack {
                    Text("\(viewState.currentStreak.value)")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .bold()
                        .foregroundStyle(Color.orange)
                    Text(viewState.currentStreak.title)
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .bold()
                }
            }
            
            Text(viewState.subtitle)
                .multilineTextAlignment(.center)
                .font(.footnote)
                .bold()
            
            Rectangle()
                .frame(height: 2)
                .background(Color.primary)
                .cornerRadius(.radius_xsmall)
            
            buildMeaningSection(from: viewState.meaning)
            
            Spacer()
        }
        .padding([.horizontal], .space_32pt)
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    func buildMeaningSection(from meaning: FinishedGameViewState.Meaning) -> some View {
        switch meaning {
        case .loading:
            ProgressView()
        case let .error(message, word):
            VStack(spacing: .space_16pt) {
                Text(message)
                    .multilineTextAlignment(.center)
                    .font(bodyFont)
                Text(word)
                    .font(titleFont)
            }
        case let .meaning(viewState):
            buildMeaningView(from: viewState)
        }
    }
    
    @ViewBuilder
    func buildMeaningView(from viewState: FinishedGameViewState.Meaning.MeaningViewState) -> some View {
        VStack(alignment: .leading, spacing: .space_16pt) {
            HStack {
                Text(viewState.word)
                    .font(titleFont)
                Spacer()
            }
            
            viewState.selectedMeaning.map { selectedMeaning in
                VStack(alignment: .leading, spacing: .space_16pt) {
                    
                    Picker("", selection: .init(get: {
                        selectedMeaning
                    }, set: {
                        viewState.onSelectMeaning($0)
                    })) {
                        ForEach(viewState.meanings) {
                            Text($0.type)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.palette)
                    .tint(Color.blue)
                    
                    Text("DEFINITIONS")
                        .font(bodyFont)
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(selectedMeaning.definitions) { def in
                                HStack(alignment: .top) {
                                    Text("\(def.index).")
                                        .font(bodyFont)
                                        .bold()
                                    
                                    Text(def.definition)
                                        .font(.callout)
                                    Spacer()
                                }
                                .padding([.horizontal], .space_32pt)
                            }
                            .animation(.easeIn(duration: 0.1), value: selectedMeaning)
                        }
                    }
                    .padding([.horizontal], -.space_32pt)
                }
            }
        }
    }
}

struct FinishedGameViewState: Equatable {
    let title: String
    let currentStreak: Streak
    let totalPlayed: Streak
    let meaning: FinishedGameViewState.Meaning
    let subtitle: String
}

extension FinishedGameViewState {
    struct Streak: Equatable {
        let title: String
        let value: Int
    }
}

extension FinishedGameViewState {
    enum Meaning: Equatable {
        case loading
        case error(message: String, word: String)
        case meaning(viewState: MeaningViewState)
    }
}

extension FinishedGameViewState.Meaning {
    struct MeaningViewState: Equatable {
        let word: String
        let meanings: [Meaning]
        let selectedMeaning: Meaning?
        let onSelectMeaning: (Meaning) -> Void
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.word == rhs.word &&
            lhs.meanings == rhs.meanings &&
            lhs.selectedMeaning == rhs.selectedMeaning
        }
    }
}

extension FinishedGameViewState.Meaning.MeaningViewState {
    struct Meaning: Equatable, Identifiable, Hashable {
        let id: String
        let type: String
        let definitions: [Definition]
    }
}

extension FinishedGameViewState.Meaning.MeaningViewState.Meaning {
    struct Definition: Equatable, Identifiable, Hashable {
        let id: String
        let index: Int
        let definition: String
    }
}

extension FinishedGameViewState {
    static let empty: Self = .init(
        title: "",
        currentStreak: .init(title: "Current streak", value: 1),
        totalPlayed: .init(title: "Played", value: 2),
        meaning: .loading,
        subtitle: ""
    )
}

extension FinishedGameViewState.Meaning.MeaningViewState.Meaning {
    static let empty: Self = .init(id: "", type: "", definitions: [])
}

#Preview {
    FinishedGameView(viewState: .init(
        title: "Great job!",
        currentStreak: .init(title: "Current streak", value: 1),
        totalPlayed: .init(title: "Played", value: 2),
        meaning: .error(message: "You’ve solved today’s puzzle. The word was", word: "ABCDE"),
        subtitle: "Come back tomorrow for another challenge!"
    ))
//    FinishedGameView(viewState: .init(
//        title: "Great job!",
//        meaning: .meaning(viewState:
//                .init(
//                    word: "ABCDE",
//                    meanings: [
//                        .init(
//                            id: "0",
//                            type: "noun",
//                            definitions: [
//                                .init(
//                                    id: "0",
//                                    index: 1,
//                                    definition: "very special noun, very special noun, very special noun"
//                                ),
//                                .init(
//                                    id: "1",
//                                    index: 2,
//                                    definition: "very special noun, very special noun, very special noun - No. 2"
//                                )
//                            ]
//                        ),
//                        .init(
//                            id: "1",
//                            type: "verb",
//                            definitions: [
//                                .init(
//                                    id: "0",
//                                    index: 0,
//                                    definition: "very special verb, very special verb, very special verb, very special verb"
//                                )
//                            ]
//                        )
//                    ],
//                    selectedMeaning: .init(id: .init(), type: "noun", definitions: [.init(id: "0", index: 0, definition: "very special noun, very special noun, very special noun")]),
//                    onSelectMeaning: { _ in }
//                )
//        ),
//        subtitle: "Come back tomorrow for another challenge!"
//    ))
}

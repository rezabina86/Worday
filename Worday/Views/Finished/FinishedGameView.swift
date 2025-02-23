import SwiftUI

struct FinishedGameView: View {
    
    init(viewModel: FinishedGameViewModelType) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: .space_16pt) {
            HStack {
                Spacer()
                Button(viewState.allWordButton.title) {
                    viewState.allWordButton.onTap.action()
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
            }
            .animation(nil, value: viewState)
            
            Text(viewState.title)
                .multilineTextAlignment(.center)
                .font(titleFont2)
                .bold()
                .animation(nil, value: viewState)
            
            Text(viewState.subtitle)
                .multilineTextAlignment(.center)
                .font(.footnote)
                .bold()
                .animation(nil, value: viewState)
            
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
            .animation(nil, value: viewState)
            
            Rectangle()
                .frame(height: 2)
                .background(Color.primary)
                .cornerRadius(.radius_xsmall)
                .animation(nil, value: viewState)
            
            buildMeaningSection(from: viewState.meaning)
                .animation(.easeIn(duration: 0.3), value: viewState.meaning)
            
            Spacer()
        }
        .padding([.horizontal], .space_32pt)
        .ignoresSafeArea(edges: .bottom)
        .task {
            for await vs in viewModel.viewState.values {
                self.viewState = vs
            }
        }
    }
    
    // MARK: - Privates
    private let viewModel: FinishedGameViewModelType
    @State private var viewState: FinishedGameViewState = .empty
    
    @ViewBuilder
    private func buildMeaningSection(from meaning: FinishedGameViewState.Meaning) -> some View {
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
    private func buildMeaningView(from viewState: FinishedGameViewState.Meaning.MeaningViewState) -> some View {
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
                        }
                    }
                    .padding([.horizontal], -.space_32pt)
                    .animation(.easeIn(duration: 0.3), value: viewState.selectedMeaning)
                }
            }
        }
    }
}

struct FinishedGameViewState: Equatable {
    let allWordButton: AllWordButton
    let title: String
    let currentStreak: Streak
    let totalPlayed: Streak
    let meaning: FinishedGameViewState.Meaning
    let subtitle: String
}

extension FinishedGameViewState {
    struct AllWordButton: Equatable {
        let title: String
        let onTap: UserAction
    }
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
        allWordButton: .init(title: "", onTap: .empty),
        title: "",
        currentStreak: .init(title: "", value: 0),
        totalPlayed: .init(title: "", value: 0),
        meaning: .loading,
        subtitle: ""
    )
}

extension FinishedGameViewState.Meaning.MeaningViewState.Meaning {
    static let empty: Self = .init(id: "", type: "", definitions: [])
}

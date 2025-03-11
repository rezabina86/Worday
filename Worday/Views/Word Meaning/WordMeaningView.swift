import SwiftUI

struct WordMeaningView: View {
    
    init(viewModel: WordMeaningViewModelType) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            WDBackground()
            makeBody(with: viewState)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: viewState)
                .padding([.leading, .trailing, .bottom], .space_32pt)
                .padding(.top, .space_8pt)
                .ignoresSafeArea(edges: .bottom)
        }
        .task {
            for await vs in viewModel.viewState.values {
                self.viewState = vs
            }
        }
    }
    
    // MARK: - Privates
    @State private var viewState: WordMeaningViewState = .loading
    private let viewModel: WordMeaningViewModelType
    
    @ViewBuilder
    private func makeBody(with viewState: WordMeaningViewState) -> some View {
        switch viewState {
        case .loading:
            ProgressView()
            Spacer()
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
                .animation(.easeIn(duration: 0.3), value: viewState)
        }
    }
    
    @ViewBuilder
    private func buildMeaningView(from viewState: WordMeaningViewState.MeaningViewState) -> some View {
        VStack(alignment: .leading, spacing: .space_16pt) {
            HStack {
                Text(viewState.word)
                    .font(titleFont)
                Spacer()
            }
            .animation(nil, value: viewState)
            
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

enum WordMeaningViewState: Equatable {
    case loading
    case error(message: String, word: String)
    case meaning(viewState: MeaningViewState)
}

extension WordMeaningViewState {
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

extension WordMeaningViewState.MeaningViewState {
    struct Meaning: Equatable, Identifiable, Hashable {
        let id: String
        let type: String
        let definitions: [Definition]
    }
}

extension WordMeaningViewState.MeaningViewState.Meaning {
    struct Definition: Equatable, Identifiable, Hashable {
        let id: String
        let index: Int
        let definition: String
    }
}

import SwiftUI

/// The single extension point that maps a `NavigationDestination` to the screen behind it. This is the
/// only place that knows concrete pushed views — `NavigationHostModifier` stays agnostic. Adding a
/// destination means adding a case here (and injecting whatever builder its screen needs), never
/// touching the host.
@MainActor
protocol NavigationDestinationViewProviderType {
    func view(for destination: NavigationDestination) -> AnyView
}

struct NavigationDestinationViewProvider: NavigationDestinationViewProviderType {

    // MARK: - Life Cycle

    init(
        wordListViewStateConverter: WordListViewStateConverterType,
        wordMeaningViewModelFactory: WordMeaningViewModelFactoryType
    ) {
        self.wordListViewStateConverter = wordListViewStateConverter
        self.wordMeaningViewModelFactory = wordMeaningViewModelFactory
    }

    // MARK: - Publics

    func view(for destination: NavigationDestination) -> AnyView {
        AnyView(destinationView(for: destination))
    }

    // MARK: - Privates

    private let wordListViewStateConverter: WordListViewStateConverterType
    private let wordMeaningViewModelFactory: WordMeaningViewModelFactoryType

    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .wordList:
            WordListView(viewState: wordListViewStateConverter.make())
        case let .wordMeaning(word):
            WordMeaningView(viewModel: wordMeaningViewModelFactory.make(word: word))
        }
    }
}

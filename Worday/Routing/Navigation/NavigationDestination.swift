import Foundation

/// Every screen the app can push onto the navigation stack, as a single closed set of cases. A feature
/// pushes one via `NavigationRouterType.push(_:)`; the case's associated values carry whatever the
/// destination needs — kept lightweight and value-typed (strings/ids, never a view model or view state)
/// so navigation can't smuggle mutable reference state and the enum stays `Hashable` for the typed path.
enum NavigationDestination: Hashable {
    /// The full played-word list, pushed from the finished screen's "All words" button.
    case wordList
    /// The dictionary meaning for one played word, pushed from a word-list row. Carries only the word;
    /// the provider builds the screen's view model from it.
    case wordMeaning(word: String)
}

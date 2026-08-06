import SwiftUI
import Observation

enum NavigationDestination {
    case wordList(viewState: WordListViewState)
    case wordMeaning(viewModel: WordMeaningViewModelType)
    case none
}

protocol NavigationRouterType: AnyObject {
    var path: NavigationPath { get set }
    func gotoDestination(_ destination: NavigationDestination)
}

@Observable
final class NavigationRouter: NavigationRouterType {

    // MARK: - Publics

    var path = NavigationPath()

    func gotoDestination(_ destination: NavigationDestination) {
        path.append(destination)
    }
}

extension NavigationDestination: Hashable {

    var id: String {
        switch self {
        case .wordList:
            "word_list_view"
        case .wordMeaning:
            "word_meaning_view"
        case .none:
            "none"
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        lhs.id == rhs.id
    }
}

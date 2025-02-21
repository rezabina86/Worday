import SwiftUI
import Combine
import Foundation

enum NavigationDestination {
    case wordList(viewState: WordListViewState)
    case wordMeaning(viewModel: WordMeaningViewModelType)
    case none
}

protocol NavigationRouterType {
    var currentPath: AnyPublisher<NavigationPath, Never> { get }
    func setCurrentPath(_ path: NavigationPath)
    
    func gotoDestination(_ destination: NavigationDestination)
}

final class NavigationRouter: NavigationRouterType {
    
    var currentPath: AnyPublisher<NavigationPath, Never> {
        currentPathSubject.eraseToAnyPublisher()
    }
    
    func setCurrentPath(_ path: NavigationPath) {
        currentPathSubject.send(path)
    }
    
    func gotoDestination(_ destination: NavigationDestination) {
        var currentPath = currentPathSubject.value
        currentPath.append(destination)
        currentPathSubject.send(currentPath)
    }
    
    // MARK: - Privates
    
    private let currentPathSubject: CurrentValueSubject<NavigationPath, Never> = .init(.init())
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

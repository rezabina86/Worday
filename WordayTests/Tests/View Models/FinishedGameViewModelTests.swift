import Combine
import Testing
import Foundation
@testable import Worday

final class FinishedGameViewModelTests {
    var sut: FinishedGameViewModel!
    var mockDictionaryUseCase: DictionaryUseCaseMock
    
    private let title: String = "Great job! 🎉"
    private let subtitle: String = "Come back tomorrow for another challenge!"
    
    init() {
        mockDictionaryUseCase = .init()
        
        sut = .init(word: "abcde",
                    dictionaryUseCase: mockDictionaryUseCase)
    }
}

private extension FinishedGameViewState {
    var isLoading: Bool {
        switch self.meaning {
        case .loading: return true
        case .meaning, .error: return false
        }
    }
    
    var isError: Bool {
        switch self.meaning {
        case .error: return true
        case .loading, .meaning: return false
        }
    }
    
    var isLoaded: Bool {
        switch self.meaning {
        case .meaning: return true
        case .error, .loading: return false
        }
    }
}

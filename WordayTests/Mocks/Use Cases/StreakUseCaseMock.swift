import Foundation
@testable import Worday

final class StreakUseCaseMock: StreakUseCaseType {
    
    enum Call: Equatable {
        case calculateStreak
        case totalPlayed
    }
    
    func calculateStreak() -> Int {
        calls.append(.calculateStreak)
        return calculateStreakReturnValue
    }
    
    func totalPlayed() -> Int {
        calls.append(.totalPlayed)
        return totalPlayedReturnValue
    }
    
    private(set) var calls: [Call] = []
    var calculateStreakReturnValue: Int = 0
    var totalPlayedReturnValue: Int = 0
}

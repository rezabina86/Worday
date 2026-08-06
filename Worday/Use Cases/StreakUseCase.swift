import Foundation

protocol StreakUseCaseType {
    func calculateStreak() -> Int
    func totalPlayed() -> Int
}

struct StreakUseCase: StreakUseCaseType {
    
    init(playedWordsLibrary: PlayedWordsLibraryType,
         calendarService: CalendarServiceType) {
        self.playedWordsLibrary = playedWordsLibrary
        self.calendarService = calendarService
    }

    func totalPlayed() -> Int {
        playedWordsLibrary.words.count
    }

    func calculateStreak() -> Int {
        // Read played dates and check if the user has played yet or not
        let playedDates = playedWordsLibrary.words.map { $0.playedAt }
        guard playedDates.isEmpty == false else { return 0 }
        
        // Check if the last played date is today
        guard let lastPlayedDate = playedDates.first,
                calendarService.isDateInToday(lastPlayedDate) else { return 0 }
        
        var streak = 1
        
        // The user should have played the game more than one day
        guard playedDates.count > 1 else { return streak }
        
        var currentIndex = playedDates.index(after: playedDates.startIndex)
        
        while currentIndex < playedDates.endIndex {
            let current = playedDates[playedDates.index(before: currentIndex)]
            let dayBefore = playedDates[currentIndex]
            
            // Calculate the difference in days
            if let daysDifference = calendarService.daysBetween(from: dayBefore, to: current), daysDifference == 1 {
                streak += 1
            } else {
                break
            }
            
            currentIndex = playedDates.index(after: currentIndex)
        }
        
        return streak
    }
    
    // MARK: - Privates
    private let playedWordsLibrary: PlayedWordsLibraryType
    private let calendarService: CalendarServiceType
}

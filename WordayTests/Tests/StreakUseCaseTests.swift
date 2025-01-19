import Testing
import Foundation
@testable import Worday

struct StreakUseCaseTests {
    
    var sut: StreakUseCase
    var mockWordContext: WordStorageModelContextMock
    var mockCalendarService: CalendarServiceMock
    
    init() {
        mockWordContext = .init()
        mockCalendarService = .init()
        
        sut = .init(
            wordContext: mockWordContext,
            calendarService: mockCalendarService
        )
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        date1 = formatter.date(from: "2025-01-14 23:00")!
        date2 = formatter.date(from: "2025-01-15 23:30")!
        date3 = formatter.date(from: "2025-01-16 00:30")!
        date4 = formatter.date(from: "2025-01-17 09:30")!
        
        mockCalendarService.isDateInTodayReturnValues = [date1: true, date2: false, date3: false, date4: false]
        mockCalendarService.daysBetweenReturnValues = [
            .init(from: date2, to: date1): 1,
            .init(from: date3, to: date2): 1,
            .init(from: date4, to: date3): 1
        ]
    }

    @Test func testTotalPlayed() async throws {
        mockWordContext.fetchReturnValue = [
            .init(id: "1", word: "abcde", playedAt: .now),
            .init(id: "2", word: "abcde", playedAt: .now),
            .init(id: "3", word: "abcde", playedAt: .now)
        ]
        
        #expect(sut.totalPlayed() == 3)
    }
    
    @Test func testStreakConsecutiveDates() async throws {
        mockWordContext.fetchReturnValue = [
            .init(id: "1", word: "abcde", playedAt: date1),
            .init(id: "2", word: "abcde", playedAt: date2),
            .init(id: "3", word: "abcde", playedAt: date3)
        ]
        
        #expect(sut.calculateStreak() == 3)
    }
    
    @Test func testStreakPlayedOnce() async throws {
        mockWordContext.fetchReturnValue = [
            .init(id: "1", word: "abcde", playedAt: date1)
        ]
        
        #expect(sut.calculateStreak() == 1)
    }
    
    @Test func testStreakNonConsecutiveDates() async throws {
        mockWordContext.fetchReturnValue = [
            .init(id: "1", word: "abcde", playedAt: date1),
            .init(id: "2", word: "abcde", playedAt: date3),
            .init(id: "3", word: "abcde", playedAt: date4)
        ]
        
        #expect(sut.calculateStreak() == 1)
    }
    
    @Test func testStreakNotPlayedToday() async throws {
        mockWordContext.fetchReturnValue = [
            .init(id: "2", word: "abcde", playedAt: date3),
            .init(id: "3", word: "abcde", playedAt: date4)
        ]
        
        #expect(sut.calculateStreak() == 0)
    }
    
    // MARK: - Helpers
    let formatter = DateFormatter()
    let date1: Date
    let date2: Date
    let date3: Date
    let date4: Date
}

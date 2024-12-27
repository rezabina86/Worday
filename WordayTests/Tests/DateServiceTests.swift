import Testing
import Foundation
@testable import Worday

struct DateServiceTests {
    
    var sut: DateService!
    
    init() {
        sut = .init()
    }

    @Test func testTodayMethod() async throws {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        
        #expect(sut.isDateInToday(now) == true)
        #expect(sut.isDateInToday(yesterday) == false)
    }
}

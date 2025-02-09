import Testing
import Foundation
@testable import Worday

struct AttemptTrackerUseCaseTests {
    var sut: AttemptTrackerUseCase
    var mockUserSettings: UserSettingsMock
    
    private let testSubscriber: TestableSubscriber<Int, Never>
    
    init() {
        mockUserSettings = .init()
        sut = .init(userSettings: mockUserSettings)
        
        testSubscriber = .init()
        sut.numberOfTries
            .subscribe(testSubscriber)
    }
    
    @Test func testCleanup() async throws {
        sut.advance()
        sut.cleanup()
        
        #expect(mockUserSettings.setNumberOfTriesCall == [
            .numberOfTries(.set(1)),
            .numberOfTries(.set(nil))
        ])
        
        #expect(testSubscriber.receivedValues == [0, 1, 0])
    }
    
    @Test func testAdvance() async throws {
        #expect(mockUserSettings.getNumberOfTriesCall == [.numberOfTries(.get)])
        
        sut.advance()
        sut.advance()
        
        #expect(mockUserSettings.setNumberOfTriesCall == [
            .numberOfTries(.set(1)),
            .numberOfTries(.set(2))
        ])
        
        #expect(testSubscriber.receivedValues == [0, 1, 2])
    }
}

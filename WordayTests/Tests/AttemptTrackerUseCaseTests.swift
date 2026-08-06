import Testing
import Foundation
@testable import Worday

struct AttemptTrackerUseCaseTests {
    let sut: AttemptTrackerUseCase
    let mockUserSettings: UserSettingsMock

    init() {
        mockUserSettings = .init()
        sut = .init(userSettings: mockUserSettings)
    }

    @Test("it seeds from user settings and advances the counter, persisting each step")
    func advance() {
        #expect(mockUserSettings.getNumberOfTriesCall == [.numberOfTries(.get)])
        #expect(sut.numberOfTries == 0)

        sut.advance()
        #expect(sut.numberOfTries == 1)

        sut.advance()
        #expect(sut.numberOfTries == 2)

        #expect(mockUserSettings.setNumberOfTriesCall == [
            .numberOfTries(.set(1)),
            .numberOfTries(.set(2))
        ])
    }

    @Test("it resets the counter and clears the persisted value")
    func cleanup() {
        sut.advance()
        #expect(sut.numberOfTries == 1)

        sut.cleanup()
        #expect(sut.numberOfTries == 0)

        #expect(mockUserSettings.setNumberOfTriesCall == [
            .numberOfTries(.set(1)),
            .numberOfTries(.set(nil))
        ])
    }

    @Test("it renders the ordinal for the current try count")
    func ordinalString() {
        sut.advance()
        #expect(sut.ordinalString() == "1st")

        sut.advance()
        #expect(sut.ordinalString() == "2nd")

        sut.advance()
        #expect(sut.ordinalString() == "3rd")

        sut.advance()
        #expect(sut.ordinalString() == "4th")
    }
}

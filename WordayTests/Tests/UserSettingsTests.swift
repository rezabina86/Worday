import Testing
import Foundation
@testable import Worday

struct UserSettingsTests {
    
    var sut: UserSettings!
    var mockUserDefaults: UserDefaultsMock!
    
    init() {
        mockUserDefaults = .init()
        sut = .init(userDefaults: mockUserDefaults)
    }

    @Test func testSettingCurrentWord() async throws {
        sut.currentWord = "a"
        
        // Writes the data once
        #expect(mockUserDefaults.setForKeyCalls.count == 1)
        
        //Writes data using the correct key
        #expect(mockUserDefaults.setForKeyCalls.first!.forKey == "current_word")
        
        //Writes the correct data
        #expect(mockUserDefaults.setForKeyCalls.first?.value as? String == "a")
    }
    
    @Test func testSettingCurrentWordToNil() async throws {
        sut.currentWord = nil
        
        // Writes the data once
        #expect(mockUserDefaults.setForKeyCalls.count == 1)
        
        //Writes data using the correct key
        #expect(mockUserDefaults.setForKeyCalls.first!.forKey == "current_word")
        
        //Writes the correct data
        #expect(mockUserDefaults.setForKeyCalls.first?.value as? String == nil)
    }
    
    @Test func testReset() async throws {
        sut.reset()
        
        // Writes the data once
        #expect(mockUserDefaults.setForKeyCalls.count == 1)
        
        //Writes data using the correct key
        #expect(mockUserDefaults.setForKeyCalls.first!.forKey == "current_word")
        
        //Writes the correct data
        #expect(mockUserDefaults.setForKeyCalls.first?.value as? String == nil)
    }
}

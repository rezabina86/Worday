import Testing
import SwiftUI
import Foundation
@testable import Worday

struct NavigationRouterTests {
    var sut: NavigationRouter
    private let testSubscriber: TestableSubscriber<NavigationPath, Never>
    
    init() {
        sut = .init()
        
        testSubscriber = .init()
        sut.currentPath
            .dropFirst()
            .subscribe(testSubscriber)
    }
    
    @Test func testSetCurrentPath() async throws {
        sut.setCurrentPath(.init([NavigationDestination.testDestination]))
        
        #expect(testSubscriber.receivedValues == [.init([NavigationDestination.testDestination])])
    }
    
    @Test func testGotoDestination() async throws {
        sut.gotoDestination(.testDestination)
        
        #expect(testSubscriber.receivedValues == [.init([NavigationDestination.testDestination])])
    }
}

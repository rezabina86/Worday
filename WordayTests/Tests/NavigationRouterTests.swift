import Testing
import SwiftUI
import Foundation
@testable import Worday

struct NavigationRouterTests {
    let sut: NavigationRouter

    init() {
        sut = .init()
    }

    @Test("it starts with an empty path")
    func startsEmpty() {
        #expect(sut.path == NavigationPath())
    }

    @Test("setting the path replaces it")
    func setPath() {
        sut.path = NavigationPath([NavigationDestination.none])

        #expect(sut.path == NavigationPath([NavigationDestination.none]))
    }

    @Test("goto appends the destination to the path")
    func gotoDestination() {
        sut.gotoDestination(.none)

        #expect(sut.path == NavigationPath([NavigationDestination.none]))
    }
}

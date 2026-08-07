import Testing
@testable import Worday

struct NavigationRouterTests {
    let sut = NavigationRouter()

    @Test("it starts with an empty path")
    func startsEmpty() {
        #expect(sut.path == [])
    }

    @Test("push appends the destination")
    func pushAppends() {
        sut.push(.wordList)
        sut.push(.wordMeaning(word: "cat"))

        #expect(sut.path == [.wordList, .wordMeaning(word: "cat")])
    }

    @Test("pop removes the last destination")
    func popRemovesLast() {
        sut.push(.wordList)
        sut.push(.wordMeaning(word: "cat"))

        sut.pop()

        #expect(sut.path == [.wordList])
    }

    @Test("pop on an empty path is a no-op")
    func popEmptyIsNoOp() {
        sut.pop()
        #expect(sut.path == [])
    }

    @Test("popToRoot clears the path")
    func popToRootClears() {
        sut.push(.wordList)
        sut.push(.wordMeaning(word: "cat"))

        sut.popToRoot()

        #expect(sut.path == [])
    }

    @Test("setPath replaces the path (routes system pops)")
    func setPathReplaces() {
        sut.push(.wordList)

        sut.setPath([.wordMeaning(word: "dog")])

        #expect(sut.path == [.wordMeaning(word: "dog")])
    }
}

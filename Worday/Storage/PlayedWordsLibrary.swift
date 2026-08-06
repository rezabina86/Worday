import Observation

/// The single observable window onto the player's stored words. A `.container`-scoped `@Observable`
/// read-projection over `WordStorageModelContextType`: the store stays the source of truth and this only
/// ever *derives* from it (`load()` at launch, `reload()` after a word is stored), so the display
/// surfaces that read it — the word list and the streak — can never disagree with each other. Readers
/// take `PlayedWordsLibraryType` instead of hitting the store directly; the writer
/// (`WordProviderUseCase`) calls `reload()` after saving.
@MainActor
protocol PlayedWordsLibraryType: AnyObject {
    var words: [WordStorageEntity] { get }
    func load()
    func reload()
}

@Observable
final class PlayedWordsLibrary: PlayedWordsLibraryType {

    // MARK: - Life Cycle

    init(wordContext: WordStorageModelContextType) {
        self.wordContext = wordContext
    }

    // MARK: - Publics

    private(set) var words: [WordStorageEntity] = []

    func load() {
        reload()
    }

    func reload() {
        words = (try? wordContext.fetchAll()) ?? []
    }

    // MARK: - Privates

    @ObservationIgnored private let wordContext: WordStorageModelContextType
}

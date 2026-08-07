import Foundation
import SwiftData

extension ContainerType {
    /// The SwiftData persistence seam and the shared `@Observable` read-projection over it.
    func registerStorageDependencies() {
        // One shared main context for the app's lifetime: the writer and any reader operate on the same
        // `ModelContext` over `sharedModelContainer`, so an insert is immediately visible to a fetch and
        // there is a single stable identity (`===` in `DependencyGraphTests`).
        register(in: .container) { _ in ModelContext(sharedModelContainer) as WordStorageModelContextType }

        register(in: .container) { container in
            PlayedWordsLibrary(wordContext: container.resolve()) as PlayedWordsLibraryType
        }
    }
}

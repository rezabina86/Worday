import Foundation
import SwiftData

extension ContainerType {
    /// The SwiftData persistence seam and the shared `@Observable` read-projection over it.
    func registerStorageDependencies() {
        register { _ in ModelContext(sharedModelContainer) as WordStorageModelContextType }

        register(in: .container) { container in
            PlayedWordsLibrary(wordContext: container.resolve()) as PlayedWordsLibraryType
        }
    }
}

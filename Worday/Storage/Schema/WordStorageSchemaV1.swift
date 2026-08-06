import SwiftData
import Foundation

/// The original persisted schema — `WordStorageEntity.id` is a plain `String`. This is what every
/// already-shipped install has on disk; it exists only so the migration plan can read the old store and
/// carry its rows forward to V2. New code uses the top-level `WordStorageEntity` (= the latest version).
enum WordStorageSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [WordStorageEntity.self] }

    @Model
    final class WordStorageEntity {
        var id: String
        var word: String
        var playedAt: Date

        init(id: String, word: String, playedAt: Date) {
            self.id = id
            self.word = word
            self.playedAt = playedAt
        }
    }
}

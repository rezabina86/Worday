import SwiftData
import Foundation

/// The current persisted schema — `WordStorageEntity.id` is an `EntityID<WordStorageEntity>`. The
/// top-level `WordStorageEntity` typealias points here, so all app code uses this version; older stores
/// are brought forward by `WordStorageMigrationPlan`.
enum WordStorageSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(2, 0, 0) }
    static var models: [any PersistentModel.Type] { [WordStorageEntity.self] }

    @Model
    final class WordStorageEntity: Equatable {
        var id: EntityID<WordStorageEntity>
        var word: String
        var playedAt: Date

        init(id: EntityID<WordStorageEntity>, word: String, playedAt: Date) {
            self.id = id
            self.word = word
            self.playedAt = playedAt
        }

        static func == (lhs: WordStorageEntity, rhs: WordStorageEntity) -> Bool {
            lhs.id == rhs.id && lhs.word == rhs.word && lhs.playedAt == rhs.playedAt
        }
    }
}

/// The app always refers to the latest `WordStorageEntity`.
typealias WordStorageEntity = WordStorageSchemaV2.WordStorageEntity

import SwiftData
import Foundation

/// Migrates the persisted store from V1 (`id: String`) to V2 (`id: EntityID<WordStorageEntity>`).
///
/// SwiftData can't automatically map a property whose *type* changed, so the custom stage does it by
/// hand and **preserves every field, including the id value**: `willMigrate` reads the V1 rows into
/// memory and empties the store (so the structural V1→V2 change runs against an empty store and can't
/// choke on the incompatible `id` column); `didMigrate` re-inserts them as V2 rows, wrapping the old id
/// string in an `EntityID`. Word and played-date — the data the game actually uses — always survive.
enum WordStorageMigrationPlan: SchemaMigrationPlan {

    static var schemas: [any VersionedSchema.Type] {
        [WordStorageSchemaV1.self, WordStorageSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    // MARK: - Privates

    private struct Carried {
        let id: String
        let word: String
        let playedAt: Date
    }

    // The rows read in `willMigrate` and re-inserted in `didMigrate`. Migration is sequential (one stage,
    // will-then-did) during container init, so there is no concurrent access. Both callbacks must run in
    // the same migration pass: `willMigrate` empties and *saves* the store, so a process kill between the
    // two would leave the store empty (the drain-empty-refill tradeoff for a non-mappable type change).
    private nonisolated(unsafe) static var carried: [Carried] = []

    private static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: WordStorageSchemaV1.self,
        toVersion: WordStorageSchemaV2.self,
        willMigrate: { context in
            let old = try context.fetch(FetchDescriptor<WordStorageSchemaV1.WordStorageEntity>())
            carried = old.map { Carried(id: $0.id, word: $0.word, playedAt: $0.playedAt) }
            for row in old { context.delete(row) }
            try context.save()
        },
        didMigrate: { context in
            for record in carried {
                context.insert(
                    WordStorageEntity(
                        id: EntityID(rawValue: record.id),
                        word: record.word,
                        playedAt: record.playedAt
                    )
                )
            }
            try context.save()
            carried = []
        }
    )
}

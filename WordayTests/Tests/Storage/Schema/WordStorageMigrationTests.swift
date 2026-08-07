import Testing
import SwiftData
import Foundation
@testable import Worday

/// Verifies the **real upgrade path** for the `EntityID` migration: a persisted V1 store (`id: String`)
/// opened with the V2 schema + `WordStorageMigrationPlan` must carry every row forward intact. A
/// fresh-install run can't catch a broken migration, so this exercises a real on-disk V1 store.
struct WordStorageMigrationTests {

    @Test("a V1 (String id) store migrates to V2 (EntityID) preserving word, date, and id")
    func migratesV1StoreToV2() throws {
        let url = makeStoreURL()
        defer { removeStore(at: url) }

        let playedAt = Date(timeIntervalSince1970: 1_000)

        // 1. Write an old (V1) store with a String id — what a shipped install has on disk.
        try writeV1Store(at: url) { context in
            context.insert(WordStorageSchemaV1.WordStorageEntity(id: "uuid-123", word: "CAT", playedAt: playedAt))
        }

        // 2. Open the same store with the current schema + migration plan.
        let rows = try openV2AndFetch(at: url)

        // 3. Every field survived, and the id is now the wrapped EntityID.
        #expect(rows.count == 1)
        #expect(rows.first?.word == "CAT")
        #expect(rows.first?.playedAt == playedAt)
        #expect(rows.first?.id == EntityID(rawValue: "uuid-123"))
    }

    @Test("an empty V1 store migrates to an empty V2 store")
    func migratesEmptyV1Store() throws {
        let url = makeStoreURL()
        defer { removeStore(at: url) }

        try writeV1Store(at: url) { _ in }

        let rows = try openV2AndFetch(at: url)

        #expect(rows.isEmpty)
    }

    @Test("a multi-row V1 store migrates carrying every row forward")
    func migratesMultiRowV1Store() throws {
        let url = makeStoreURL()
        defer { removeStore(at: url) }

        let seed: [(id: String, word: String, playedAt: Date)] = [
            (id: "1", word: "CAT", playedAt: Date(timeIntervalSince1970: 1_000)),
            (id: "2", word: "DOG", playedAt: Date(timeIntervalSince1970: 2_000)),
            (id: "3", word: "FOX", playedAt: Date(timeIntervalSince1970: 3_000))
        ]

        try writeV1Store(at: url) { context in
            for row in seed {
                context.insert(WordStorageSchemaV1.WordStorageEntity(id: row.id, word: row.word, playedAt: row.playedAt))
            }
        }

        let rows = try openV2AndFetch(at: url)

        #expect(rows.count == seed.count)
        // Every seeded row survived with its id, word, and date — compared order-independently.
        for row in seed {
            let match = rows.first { $0.id == EntityID(rawValue: row.id) }
            #expect(match?.word == row.word)
            #expect(match?.playedAt == row.playedAt)
        }
    }

    // MARK: - Helpers

    private func makeStoreURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("worday-migration-test-\(UUID().uuidString).store")
    }

    private func writeV1Store(at url: URL, _ insert: (ModelContext) -> Void) throws {
        let v1Schema = Schema(versionedSchema: WordStorageSchemaV1.self)
        let container = try ModelContainer(
            for: v1Schema,
            configurations: ModelConfiguration(schema: v1Schema, url: url)
        )
        let context = ModelContext(container)
        insert(context)
        try context.save()
    }

    private func openV2AndFetch(at url: URL) throws -> [WordStorageEntity] {
        let v2Schema = Schema(versionedSchema: WordStorageSchemaV2.self)
        let v2Container = try ModelContainer(
            for: v2Schema,
            migrationPlan: WordStorageMigrationPlan.self,
            configurations: ModelConfiguration(schema: v2Schema, url: url)
        )
        return try ModelContext(v2Container).fetch(FetchDescriptor<WordStorageEntity>())
    }

    private func removeStore(at url: URL) {
        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(at: url.appendingPathExtension(suffix.isEmpty ? "" : suffix))
        }
        try? FileManager.default.removeItem(at: url)
    }
}

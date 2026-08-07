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
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("worday-migration-test-\(UUID().uuidString).store")
        defer { removeStore(at: url) }

        let playedAt = Date(timeIntervalSince1970: 1_000)

        // 1. Write an old (V1) store with a String id — what a shipped install has on disk.
        try writeV1Store(at: url) { context in
            context.insert(WordStorageSchemaV1.WordStorageEntity(id: "uuid-123", word: "CAT", playedAt: playedAt))
        }

        // 2. Open the same store with the current schema + migration plan.
        let v2Schema = Schema(versionedSchema: WordStorageSchemaV2.self)
        let v2Container = try ModelContainer(
            for: v2Schema,
            migrationPlan: WordStorageMigrationPlan.self,
            configurations: ModelConfiguration(schema: v2Schema, url: url)
        )
        let context = ModelContext(v2Container)
        let rows = try context.fetch(FetchDescriptor<WordStorageEntity>())

        // 3. Every field survived, and the id is now the wrapped EntityID.
        #expect(rows.count == 1)
        #expect(rows.first?.word == "CAT")
        #expect(rows.first?.playedAt == playedAt)
        #expect(rows.first?.id == EntityID(rawValue: "uuid-123"))
    }

    // MARK: - Helpers

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

    private func removeStore(at url: URL) {
        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(at: url.appendingPathExtension(suffix.isEmpty ? "" : suffix))
        }
        try? FileManager.default.removeItem(at: url)
    }
}

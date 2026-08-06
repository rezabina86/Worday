# Storage Schema & Migrations

The persisted model (`WordStorageEntity`) and the versioned-schema + migration machinery that lets its
shape change without losing shipped users' data.

## Components

- **`WordStorageEntity`** — the SwiftData `@Model` for one played word (`id: EntityID<WordStorageEntity>`,
  `word`, `playedAt`). It is defined in the **latest** versioned schema and exposed to the app via
  `typealias WordStorageEntity = WordStorageSchemaV2.WordStorageEntity`, so app code always uses the
  current shape.
- **`WordStorageSchemaV1`** — the original shape (`id: String`). It exists only so the migration plan can
  read an old on-disk store; no app code uses it.
- **`WordStorageSchemaV2`** — the current shape (`id: EntityID`).
- **`WordStorageMigrationPlan`** — the `SchemaMigrationPlan` wired into `sharedModelContainer`. Because a
  property *type* change (`String` → `EntityID`) is not a lightweight migration, the custom stage carries
  data by hand: `willMigrate` reads the V1 rows into memory and empties the store (so the structural
  change runs against an empty store); `didMigrate` re-inserts them as V2, wrapping the old id string in an
  `EntityID`. **Every field survives, including the id value.**

## How to use

**Reading/writing** stored words goes through `WordStorageModelContextType` (the injected `ModelContext`
seam) and the `PlayedWordsLibrary` projection — never touch `sharedModelContainer` directly from a feature.

**Changing the model** (add/remove/retype a property):

1. Add a new `WordStorageSchemaVN` with the new shape and point the `typealias` at it.
2. Keep the previous version(s) intact.
3. Add a `MigrationStage` to `WordStorageMigrationPlan` (lightweight for add/remove; **custom** for a type
   change, following the drain-empty-refill pattern above so data is preserved).
4. **Add a migration test.** A fresh-install run cannot catch a broken migration.
   `WordStorageMigrationTests` writes a real on-disk store in the *old* schema, re-opens it with the new
   schema + plan, and asserts every row survived. Do the same for the new stage.

Never change a persisted `@Model` property in place without a version + stage + test — existing installs
would crash at `ModelContainer` init (the `fatalError` in `sharedModelContainer`).

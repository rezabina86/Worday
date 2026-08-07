# Storage

On-device persistence for the player's played-word history (SwiftData), plus the observable projection the
display surfaces read from.

## Components

- **`WordStorageEntity`** — the SwiftData `@Model` for one played word (`id`, `word`, `playedAt`). Its
  shape is versioned; see `Schema/StorageSchema.md`.
- **`sharedModelContainer`** — the app's single `ModelContainer`, wired with `WordStorageMigrationPlan` so
  older stores upgrade on launch.
- **`WordStorageModelContextType`** — the injected seam over `ModelContext` (`insert`/`save`/`fetchAll`),
  registered `.container` so the writer and every reader share one context over `sharedModelContainer`.
  The **write path** goes through this (the game stores a word when solved).
- **`PlayedWordsLibrary`** (`PlayedWordsLibraryType`, `@Observable`, `.container`) — the single observable
  read-projection over the store. The store stays the source of truth; the library only derives from it
  via `reload()` (called once at launch to hydrate, and again after each write). A failed fetch keeps the
  last-known-good words rather than blanking them. See CLAUDE.md → "Shared Store Projections".

## How to use

**Read** the played words from the shared projection — never call `fetchAll()` from a feature:

```swift
playedWordsLibrary.words        // [WordStorageEntity], observable
```

Readers inject `PlayedWordsLibraryType` (e.g. `StreakUseCase`, `WordListViewStateConverter`).

**Write** a word (the game's write-owner, `WordProviderUseCase`):

```swift
wordContext.insert(.init(id: .init(rawValue: uuidProvider.create()), word: word, playedAt: dateProvider.now()))
try? wordContext.save()
playedWordsLibrary.reload()     // refresh the projection so every reader re-renders
```

The library is hydrated once at launch in `WordayApp.init` via `reload()`.

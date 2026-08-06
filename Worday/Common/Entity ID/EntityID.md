# EntityID

`EntityID<Entity>` is a phantom-typed identifier — a `String` raw value tagged with the entity it
identifies — so the compiler stops one entity's id being used where another's belongs.

## What it is

```swift
nonisolated struct EntityID<Entity>: Hashable, Sendable, Codable {
    let rawValue: String
}
```

- The `Entity` parameter is **compile-time only** — nothing about it is stored; only `rawValue` is
  encoded. `EntityID<WordStorageEntity>` and `EntityID<SomeOther>` are distinct, incompatible types.
- **`nonisolated`** because the module is main-actor-by-default but an id is a plain value that SwiftData
  (persistence) and `Codable` touch off the main actor.
- Encodes/decodes as the **bare string** (a `singleValueContainer`), so its on-disk / on-wire form is just
  the id — no wrapper keys.

## How to use

**Type a genuine entity's id** with it, and mint one from a raw string:

```swift
var id: EntityID<WordStorageEntity>              // a @Model property, a value-state field
let id = EntityID<WordStorageEntity>(rawValue: uuidProvider.create())
someEntity.id.rawValue                            // the underlying string, if you need it
```

**When to use — and when not.** Use `EntityID` for a **real entity identity** (a persisted record, a
domain value with its own identity). Do **not** wrap a purely **positional `ForEach` render-key** (a
keyboard key, a character tile, an enumerated meaning/definition index) — those stay `String`;
phantom-typing a list position buys nothing and is ceremony.

**Persistence note.** Changing a persisted `@Model` id to `EntityID` is a SwiftData **schema change** —
it needs a versioned schema + migration plan proven by a migration test. See `Storage/Schema/StorageSchema.md`.

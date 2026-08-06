import Foundation

/// A phantom-typed identifier: a `String` raw value tagged with the entity it identifies, so the
/// compiler stops an `EntityID<WordStorageEntity>` from being used where some other entity's id is
/// expected. `Codable`/`Sendable`/`Hashable` so it can be a SwiftData model property and a value-state
/// field. The `Entity` parameter is purely a compile-time tag — only the `rawValue` is stored/encoded.
// `nonisolated`: the module is main-actor-isolated by default, but an id is a plain value used off the
// main actor by SwiftData (persistence) and by `Codable`, so it must not inherit main-actor isolation.
nonisolated struct EntityID<Entity>: Hashable, Sendable, Codable {

    // MARK: - Life Cycle

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    // MARK: - Publics

    let rawValue: String

    // Encode/decode as the bare string, so the on-disk / on-wire form is just the id — no wrapper keys.
    init(from decoder: any Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

import Testing
import Foundation
@testable import Worday

struct EntityIDTests {

    @Test("it encodes and decodes as a bare string")
    func codableRoundTripsAsBareString() throws {
        let id = EntityID<WordStorageEntity>(rawValue: "abc")

        let data = try JSONEncoder().encode(id)
        #expect(String(data: data, encoding: .utf8) == "\"abc\"")

        let decoded = try JSONDecoder().decode(EntityID<WordStorageEntity>.self, from: data)
        #expect(decoded == id)
    }

    @Test("ids with different raw values are unequal")
    func distinctRawValuesAreUnequal() {
        #expect(EntityID<WordStorageEntity>(rawValue: "a") != EntityID<WordStorageEntity>(rawValue: "b"))
    }
}

import SwiftData
import Foundation

protocol WordStorageModelContextType {
    func insert(_ model: WordStorageEntity)
    func fetchAll() throws -> [WordStorageEntity]
    func fetch(_ descriptor: FetchDescriptor<WordStorageEntity>) throws -> [WordStorageEntity]
}

extension WordStorageModelContextType {
    func fetchAll() throws -> [WordStorageEntity] {
        try self.fetch(
            .init(sortBy: [SortDescriptor(\.playedAt, order: .reverse)])
        )
    }
}

extension ModelContext: WordStorageModelContextType {}

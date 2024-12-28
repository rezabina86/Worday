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
            .init(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        )
    }
}

extension ModelContext: WordStorageModelContextType {}

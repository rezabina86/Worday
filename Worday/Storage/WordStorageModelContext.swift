import SwiftData
import Foundation

protocol WordStorageModelContextType {
    func insert(_ model: WordStorageEntity)
    func fetchAll() throws -> Set<WordStorageEntity>
    func fetch(_ descriptor: FetchDescriptor<WordStorageEntity>) throws -> [WordStorageEntity]
}

extension WordStorageModelContextType {
    func fetchAll() throws -> Set<WordStorageEntity> {
        let entities = try self.fetch(
            .init(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        )
        
        return Set(entities)
    }
}

extension ModelContext: WordStorageModelContextType {}

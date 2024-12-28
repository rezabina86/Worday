import Foundation
import SwiftData
@testable import Worday

final class WordStorageModelContextMock: WordStorageModelContextType {
    
    enum Call: Equatable {
        case insert(model: WordStorageEntity)
        case fetchAll
        case fetch
    }
    
    func insert(_ model: WordStorageEntity) {
        calls.append(.insert(model: model))
    }
    
    func fetchAll() throws -> [WordStorageEntity] {
        calls.append(.fetchAll)
        return fetchReturnValue
    }
    
    func fetch(_ descriptor: FetchDescriptor<WordStorageEntity>) throws -> [WordStorageEntity] {
        calls.append(.fetch)
        return fetchReturnValue
    }
    
    var calls: [Call] = []
    var fetchReturnValue: [WordStorageEntity] = []
}

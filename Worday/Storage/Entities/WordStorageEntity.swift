import SwiftData
import Foundation

@Model
final class WordStorageEntity: Equatable {
    
    init(id: String, word: String) {
        self.id = id
        self.word = word
        self.createdAt = .now
    }
    
    var id: String
    var word: String
    var createdAt: Date
}

import SwiftData
import Foundation

@Model
final class WordStorageEntity: Equatable {
    
    init(id: String, word: String, playedAt: Date) {
        self.id = id
        self.word = word
        self.playedAt = playedAt
    }
    
    var id: String
    var word: String
    var playedAt: Date
    
    static func == (lhs: WordStorageEntity, rhs: WordStorageEntity) -> Bool {
        lhs.id == rhs.id && lhs.word == rhs.word && lhs.playedAt == rhs.playedAt
    }
}

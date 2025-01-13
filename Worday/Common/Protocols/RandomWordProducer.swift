import Foundation

protocol RandomWordProducerType {
    func randomElement(in words: Set<String>) -> String?
}

struct RandomWordProducer: RandomWordProducerType {
    func randomElement(in words: Set<String>) -> String? {
        words.randomElement()
    }
}


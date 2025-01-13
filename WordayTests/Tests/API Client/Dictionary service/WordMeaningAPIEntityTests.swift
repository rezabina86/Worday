import Testing
import Foundation
@testable import Worday

struct WordMeaningAPIEntityTests {
    
    @Test func testParseResponse() {
        let result: [WordMeaningAPIEntity]?
        
        result = try? JSONDecoder().decode(
            [WordMeaningAPIEntity].self,
            from: apiReturnValue.data(using: .utf8)!
        )
        
        #expect(result == [.fake(
            word: "hello",
            meanings: [
                .fake(
                    partOfSpeech: .noun,
                    definitions: [
                        .fake(definition: "an equivalent greeting.")
                    ]
                ),
                .fake(
                    partOfSpeech: .verb,
                    definitions: [
                        .fake(definition: "To greet")
                    ]
                ),
                .fake(
                    partOfSpeech: .interjection,
                    definitions: [
                        .fake(definition: "A greeting (salutation) said when meeting someone or acknowledging someone’s arrival or presence.")
                    ]
                )
            ]
        )]
        )
    }
}

private let apiReturnValue = """
[
   {
      "word":"hello",
      "meanings":[
         {
            "partOfSpeech":"noun",
            "definitions":[
               {
                  "definition":"an equivalent greeting."
               }
            ]
         },
         {
            "partOfSpeech":"verb",
            "definitions":[
               {
                  "definition":"To greet"
               }
            ]
         },
         {
            "partOfSpeech":"interjection",
            "definitions":[
               {
                  "definition":"A greeting (salutation) said when meeting someone or acknowledging someone’s arrival or presence."
               }
            ]
         }
      ]
   }
]
"""

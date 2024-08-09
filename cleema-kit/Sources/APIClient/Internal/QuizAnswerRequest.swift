//
//  Created by Kumpels and Friends on 21.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct QuizAnswerRequest {
    var quiz: UUID
    var answer: QuizAnswer
}

extension QuizAnswerRequest: Codable {
    enum CodingKeys: CodingKey {
        case quiz
        case answer
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<QuizAnswerRequest.CodingKeys> = try decoder
            .container(keyedBy: QuizAnswerRequest.CodingKeys.self)

        quiz = try container.decode(UUID.self, forKey: QuizAnswerRequest.CodingKeys.quiz)
        answer = try container.decode(QuizAnswer.self, forKey: QuizAnswerRequest.CodingKeys.answer)
    }

    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<QuizAnswerRequest.CodingKeys> = encoder
            .container(keyedBy: QuizAnswerRequest.CodingKeys.self)

        try container.encode(quiz.uuidString.lowercased(), forKey: QuizAnswerRequest.CodingKeys.quiz)
        try container.encode(answer, forKey: QuizAnswerRequest.CodingKeys.answer)
    }
}

//
//  Created by Kumpels and Friends on 21.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

enum QuizAnswer: String, Codable { case a, b, c, d }

struct QuizResponse: Codable {
    struct AnswerResponse: Codable {
        var option: QuizAnswer
        var text: String
    }

    struct GivenAnswer: Codable {
        var date: Date
        var answer: QuizAnswer
        // Do we need this? Works perfectly without it, so we comment it out and so we don't have to adjust our API
        //var anonymousUserID: UUID?
        //var uuid: UUID
        //var createdAt: Date
        //var updatedAt: Date
    }

    struct Streak: Codable {
        var participationStreak: Int
        var maxCorrectAnswerStreak: Int
        var correctAnswerStreak: Int
        var createdAt: Date
        var updatedAt: Date
    }

    var question: String
    var correctAnswer: QuizAnswer
    var explanation: String?
    var createdAt: Date
    var updatedAt: Date
    var publishedAt: Date?
    var locale: String
    var uuid: UUID
    var date: Date
    var answers: [AnswerResponse]
    var response: GivenAnswer?
    var streak: Streak?
}

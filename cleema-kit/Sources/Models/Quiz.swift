//
//  Created by Kumpels and Friends on 01.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public struct Quiz: Equatable {
    public enum Choice: String, Hashable, Identifiable, CaseIterable {
        case a, b, c, d

        public var id: Self { self }
    }

    public typealias ID = Tagged<Quiz, UUID>

    public var id: ID
    public var question: String
    public var choices: [Choice: String]
    public var correctAnswer: Choice
    public var explanation: String

    public init(
        id: ID = .init(rawValue: .init()),
        question: String,
        choices: [Choice: String],
        correctAnswer: Choice,
        explanation: String
    ) {
        self.id = id
        self.question = question
        self.choices = choices
        self.correctAnswer = correctAnswer
        self.explanation = explanation
    }
}

public struct QuizState: Equatable {
    public struct Answer: Equatable {
        public init(date: Date, choice: Quiz.Choice) {
            self.date = date
            self.choice = choice
        }

        public var date: Date
        public var choice: Quiz.Choice
    }

    public var quiz: Quiz
    public var streak: Int
    public var answer: Answer?
    public var maxSuccessStreak: Int = 0
    public var currentSuccessStreak: Int = 0

    public init(
        quiz: Quiz,
        streak: Int,
        answer: Answer? = nil,
        maxSuccessStreak: Int = 0,
        currentSuccessStreak: Int = 0
    ) {
        self.quiz = quiz
        self.streak = streak
        self.answer = answer
        self.maxSuccessStreak = maxSuccessStreak
        self.currentSuccessStreak = currentSuccessStreak
    }
}

public extension QuizState {
    var availableChoices: [Quiz.Choice] {
        guard let choice = answer?.choice else { return quiz.choices.keys.sorted(using: KeyPathComparator(\.rawValue)) }
        return [choice]
    }
}

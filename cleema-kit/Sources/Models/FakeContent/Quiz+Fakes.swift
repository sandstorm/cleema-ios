//
//  Created by Kumpels and Friends on 12.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Fakes
import Foundation
import Tagged

public extension Quiz {
    static func fake(
        id: Tagged<Quiz, UUID> = .init(rawValue: .init()),
        question: String = .sentence(),
        choices: [Choice] = Choice.allCases,
        correctAnswer: Choice = Choice.allCases.randomElement()!,
        explanation: String = .sentence()
    ) -> Self {
        .init(
            id: id,
            question: question,
            choices: choices.reduce(into: [:]) { acc, answer in
                acc[answer] = .word()
            },
            correctAnswer: correctAnswer,
            explanation: explanation
        )
    }
}

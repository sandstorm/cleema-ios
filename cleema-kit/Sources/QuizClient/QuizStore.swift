//
//  Created by Kumpels and Friends on 06.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

public actor QuizStore {
    var state: QuizState
    public func update(_ state: QuizState) {
        self.state = state
    }

    init(_ state: QuizState = QuizState(quiz: .fake(), streak: 0, answer: nil, maxSuccessStreak: 50)) {
        self.state = state
    }
}

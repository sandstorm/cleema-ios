//
//  Created by Kumpels and Friends on 31.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import UserChallengeFeature
import XCTestDynamicOverlay

extension JoinedChallenge.Answer {
    var answerAction: UserChallenge.Action {
        switch self {
        case .succeeded:
            return .succeededTapped
        case .failed:
            return .failedTapped
        }
    }
}

extension UserChallenge.Action {
    static func randomAnswer() -> Self {
        Bool.random() ? .succeededTapped : .failedTapped
    }
}

extension Challenge {
    static func from(
        title: String,
        challengeRange: ClosedRange<Date>,
        interval: Challenge.Interval = .daily
    ) -> Challenge {
        Challenge(
            title: title,
            type: .steps(3),
            interval: interval,
            startDate: challengeRange.lowerBound,
            endDate: challengeRange.upperBound
        )
    }
}

extension UserChallenge.State {
    init(
        challengeRange: ClosedRange<Date>,
        interval: Challenge.Interval = .daily,
        answers: [Int: JoinedChallenge.Answer] = [:],
        answerState: AnswerState = .answered,
        challengeTitle: String = ""
    ) {
        self.init(
            userChallenge: .init(
                challenge: .from(title: challengeTitle, challengeRange: challengeRange, interval: interval),
                answers: answers
            ),
            answerState: answerState
        )
    }

    init(challenge: JoinedChallenge, answerState: AnswerState = .answered) {
        self.init(userChallenge: challenge, answerState: answerState)
    }
}

//
//  Created by Kumpels and Friends on 31.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Models
import XCTest

class JoinedChallengeTests: XCTestCase {
    func testDailyUserChallenge() throws {
        let start = Date.beginningOf(day: 1, month: 7, year: 2_022)!
        let end = Date.endOf(day: 31, month: 7, year: 2_022)!
        var sut = JoinedChallenge(
            challenge: .init(title: "Challenge", interval: .daily, startDate: start, endDate: end),
            answers: Dictionary(uniqueKeysWithValues: (1 ... 11).map { ($0, JoinedChallenge.Answer.succeeded) })
        )

        XCTAssertEqual(11 / 31, sut.progress)

        sut.answers[12] = .failed

        XCTAssertEqual(11 / 31, sut.progress)
    }
}

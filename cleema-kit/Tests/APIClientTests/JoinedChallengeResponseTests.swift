//
//  Created by Kumpels and Friends on 17.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

@testable import APIClient
import CustomDump
import Models
import XCTest

final class ChallengeResponseTests: XCTestCase {
    func testDomainAnswersFromJoinedChallengeResponseWithoutAnswersIsEmpty() throws {
        let data = try XCTUnwrap("""
                      {
                        "createdAt": "2022-10-20T14:21:57.366Z",
                        "updatedAt": "2022-10-21T14:22:10.160Z",
                        "answers": []
                      }
        """.data(using: .utf8))

        let join = try JSONDecoder().decode(ChallengeResponse.Join.self, from: data)

        XCTAssertNoDifference([:], join.domainAnswers(for: .beginningOf(day: 20, month: 10, year: 2_022)!))
    }

    func testDomainAnswersFromJoinedChallengeResponse() throws {
        let data = try XCTUnwrap("""
                      {
                        "createdAt": "2022-10-20T14:21:57.366Z",
                        "updatedAt": "2022-10-21T14:22:10.160Z",
                        "answers": [
                          {
                            "answer": "succeeded",
                            "dayIndex": 1
                          },
                          {
                            "answer": "failed",
                            "dayIndex": 2
                          },
                          {
                            "answer": "succeeded",
                            "dayIndex": 5
                          }
                        ]
                      }
        """.data(using: .utf8))

        let join = try JSONDecoder().decode(ChallengeResponse.Join.self, from: data)

        let expected: [Int: JoinedChallenge.Answer] = [
            1: .succeeded,
            2: .failed,
            5: .succeeded
        ]

        XCTAssertNoDifference(expected, join.domainAnswers(for: .beginningOf(day: 20, month: 10, year: 2_022)!))
    }
}

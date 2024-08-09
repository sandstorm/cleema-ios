//
//  Created by Kumpels and Friends on 01.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Algorithms
import QuizFeature
import XCTest

final class QuizStateTests: XCTestCase {
    func testAvailableChoices() {
        let quiz: Quiz = .fake(choices: Quiz.Choice.allCases.randomSample(count: 3))
        var sut = QuizState(quiz: quiz, streak: 0, answer: nil, maxSuccessStreak: 0, currentSuccessStreak: 0)

        XCTAssertEqual(quiz.choices.keys.sorted { $0.rawValue < $1.rawValue }, sut.availableChoices)

        sut.answer = .init(date: Date(), choice: .d)

        XCTAssertEqual([.d], sut.availableChoices)

        sut.answer = .init(date: Date(), choice: .b)

        XCTAssertEqual([.b], sut.availableChoices)

        sut.answer = .init(date: Date(), choice: .c)

        XCTAssertEqual([.c], sut.availableChoices)

        sut.answer = .init(date: Date(), choice: .a)

        XCTAssertEqual([.a], sut.availableChoices)

        sut.answer = nil

        XCTAssertEqual(quiz.choices.keys.sorted { $0.rawValue < $1.rawValue }, sut.availableChoices)
    }
}

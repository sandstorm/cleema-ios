//
//  Created by Kumpels and Friends on 13.07.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Models
import XCTest

class ChallengeTests: XCTestCase {
    func testVeryLongDailyChallenge() throws {
        let start = Date.beginningOf(day: 1, month: 12, year: 2_021)!
        let end = Date.beginningOf(day: 12, month: 3, year: 2_023)!
        let sut = Challenge(title: "Challenge", interval: .daily, startDate: start, endDate: end)

        XCTAssertEqual(.days(467), sut.duration)
    }

    func testDailyChallenge() throws {
        let start = Date.beginningOf(day: 1, month: 12, year: 2_021)!

        let cal = Calendar.current
        for dayIndex in 0 ... 365 {
            let end = try XCTUnwrap(cal.date(bySettingHour: 23, minute: 59, second: 59, of: start.add(days: dayIndex)))

            let sut = Challenge(title: "Challenge", interval: .daily, startDate: start, endDate: end)

            XCTAssertEqual(.days(dayIndex + 1), sut.duration)
        }
    }

    func testStartAndEndDateForADailyChallengeWillBeSetToBeginAndEndOfDay() {
        let start = Date.momentOn(day: 1, month: 1, year: 2_022)
        let end = Date.momentOn(day: 1, month: 1, year: 2_022)

        let sut = Challenge(title: "Challenge", interval: .daily, startDate: start, endDate: end)

        XCTAssertEqual(start.startOfDay, sut.startDate)
        XCTAssertEqual(end.endOfDay, sut.endDate)
    }

    func testWeeklyWithEndLesserThanSevenDaysFromStartWillSetTheEndDateOneWeekAfterTheStartDate() {
        let start = Date.momentOn(day: 1, month: 8, year: 2_022)

        let sut = Challenge(title: "Challenge", interval: .weekly, startDate: start, endDate: start.add(days: 3))

        XCTAssertEqual(.weeks(1), sut.duration)
        XCTAssertEqual(start.startOfDay, sut.startDate)
        XCTAssertEqual(start.add(days: 3).endOfDay, sut.endDate)
    }

    func testWeeklyChallenge() throws {
        let start = Date.beginningOf(day: 1, month: 12, year: 2_021)!

        for weekIndex in 0 ... 15 {
            let end = start.add(days: 7 * weekIndex)

            let sut = Challenge(title: "Challenge", interval: .weekly, startDate: start, endDate: end)

            XCTAssertEqual(.weeks(weekIndex + 1), sut.duration)
            XCTAssertEqual(start.startOfDay, sut.startDate)
            XCTAssertEqual(end.endOfDay, sut.endDate)
        }
    }

    func testEndDateIsAlwaysAfterStartDateForDailyChallenges() {
        let start = Date.momentOn(day: 1, month: 1, year: 2_022)
        let end = start.add(days: -10)

        let daily = Challenge(title: "Challenge", interval: .daily, startDate: start, endDate: end)

        XCTAssertEqual(end.startOfDay, daily.startDate)
        XCTAssertEqual(start.endOfDay, daily.endDate)

        let weekly = Challenge(title: "Challenge", interval: .weekly, startDate: start, endDate: end)

        XCTAssertEqual(end.startOfDay, weekly.startDate)
        XCTAssertEqual(start.endOfDay, weekly.endDate)
    }

    func testVeryLongWeeklyChallenge() throws {
        let start = Date.beginningOf(day: 1, month: 12, year: 2_021)!
        let end = Date.beginningOf(day: 12, month: 3, year: 2_023)!
        let sut = Challenge(title: "Challenge", interval: .weekly, startDate: start, endDate: end)

        XCTAssertEqual(.weeks(67), sut.duration)
    }
}

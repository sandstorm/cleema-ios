//
//  Created by Kumpels and Friends on 10.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Overture
import UserChallengeFeature
import XCTest

@MainActor
final class UserChallengeFeatureTests: XCTestCase {
    func expectedComponents(
        for date: Date,
        index: Int,
        now: Date
    ) -> DateComponents {
        Calendar.current.dateComponents([.day], from: now, to: date.add(days: index - 1))
    }

    // MARK: - Tests -

    func testDailyChallengeFlow() async throws {
        let startDate = Date.beginningOf(day: 1, month: 1, year: 2_022)!
        let endDate = Date.beginningOf(day: 31, month: 1, year: 2_022)!
        let store = TestStore(
            initialState: .init(challengeRange: startDate ... endDate, interval: .daily),
            reducer: UserChallenge()
        )
        store.dependencies.date = .constant(startDate)
        store.dependencies.challengesClient = .noop

        store.dependencies.challengesClient.challengeByID = { _ in
            store.state.userChallenge.challenge
        }

        let numberOfDays = startDate.numberOfDays(to: endDate) + 1
        for dayNumber in 1 ... numberOfDays {
            let answer: JoinedChallenge.Answer = .allCases.randomElement()!

            await store.send(.fetch) {
                $0.answerState = .pending(
                    pendingIndex: dayNumber,
                    dateComponents: self.expectedComponents(
                        for: startDate,
                        index: dayNumber,
                        now: store.dependencies.date.now
                    )
                )
            }

            await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

            await store.send(answer.answerAction) {
                $0.userChallenge.answers[dayNumber] = answer
                $0.answerState = .answered
            }

            await store.send(answer.answerAction)

            store.dependencies.date = .constant(store.dependencies.date.now.add(days: 1))
        }

        // fully answered challenge will not add more entries
        await store.send(.succeededTapped)

        store.dependencies.date = .constant(store.dependencies.date.now.add(days: 1))
        await store.send(.succeededTapped)

        store.dependencies.date = .constant(store.dependencies.date.now.add(days: 1))
        await store.send(.failedTapped)
    }

    func testAnsweringDailyStartingBeforeStartDate() async throws {
        let startDate = Date()
        let endDate = startDate.add(days: 10)
        let store = TestStore(initialState: .init(
            challengeRange: startDate ... endDate,
            answerState: .pending(pendingIndex: 42, dateComponents: .init(day: 42))
        ), reducer: UserChallenge())
        store.dependencies.date = .constant(startDate.add(days: -1))
        store.dependencies.challengesClient = .noop
        store.dependencies.challengesClient.challengeByID = { _ in
            store.state.userChallenge.challenge
        }

        await store.send(.fetch) {
            $0.answerState = .upcoming(.init(day: 1))
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        await store.send(.succeededTapped)
        await store.send(.failedTapped)

        store.dependencies.date = .constant(startDate)

        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 1,
                dateComponents: self.expectedComponents(for: startDate, index: 1, now: store.dependencies.date.now)
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        // 2nd day
        store.dependencies.date = .constant(startDate.add(days: 1))
        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 2,
                dateComponents: self.expectedComponents(for: startDate, index: 2, now: store.dependencies.date.now)
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        // answer 2nd day after start
        await store.send(.succeededTapped) {
            $0.userChallenge.answers[2] = .succeeded
            $0.answerState = .pending(
                pendingIndex: 1,
                dateComponents: self.expectedComponents(for: startDate, index: 1, now: store.dependencies.date.now)
            )
        }

        // answer 1st day after start
        await store.send(.failedTapped) {
            $0.userChallenge.answers[1] = .failed
            $0.answerState = .answered
        }
    }

    func testAnsweringTodayAndTwoDaysBeforeSkippingAlreadyAnsweredDaysInDailyChallenge() async throws {
        let startDate = Date().add(days: -2)
        let endDate = startDate.add(days: 7)
        let store = TestStore(
            initialState: .init(challengeRange: startDate ... endDate, answers: [2: .succeeded]),
            reducer: UserChallenge()
        )
        store.dependencies.date = .constant(Date())
        store.dependencies.challengesClient = .noop
        store.dependencies.challengesClient.challengeByID = { _ in
            store.state.userChallenge.challenge
        }

        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 3,
                dateComponents: self.expectedComponents(for: startDate, index: 3, now: store.dependencies.date.now)
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        await store.send(.failedTapped) {
            $0.userChallenge.answers[3] = .failed
            $0.answerState = .pending(
                pendingIndex: 1,
                dateComponents: self.expectedComponents(for: startDate, index: 1, now: store.dependencies.date.now)
            )
        }
    }

    func testAnsweringBeyondTheEndDateOfADailyChallenge() async throws {
        let startDate = Date.beginningOf(day: 2, month: 8, year: 2_022)!
        let endDate = Date.momentOn(day: 10, month: 8, year: 2_022)
        let store = TestStore(initialState: .init(challengeRange: startDate ... endDate), reducer: UserChallenge())
        store.dependencies.date = .constant(endDate.add(days: 1))
        store.dependencies.challengesClient = .noop
        store.dependencies.challengesClient.challengeByID = { _ in
            store.state.userChallenge.challenge
        }

        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 9,
                dateComponents: self.expectedComponents(for: startDate, index: 9, now: store.dependencies.date.now)
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        await store.send(.succeededTapped) {
            $0.userChallenge.answers[9] = .succeeded
            $0.answerState = .pending(
                pendingIndex: 8,
                dateComponents: self.expectedComponents(for: startDate, index: 8, now: store.dependencies.date.now)
            )
        }

        await store.send(.succeededTapped) {
            $0.userChallenge.answers[8] = .succeeded
            $0.answerState = .pending(
                pendingIndex: 7,
                dateComponents: self.expectedComponents(for: startDate, index: 7, now: store.dependencies.date.now)
            )
        }

        await store.send(.succeededTapped) {
            $0.userChallenge.answers[7] = .succeeded
            $0.answerState = .answered
        }

        await store.send(.succeededTapped)
    }

    func testFailingBeyondTheEndDateOfADailyChallenge() async throws {
        let startDate = Date.beginningOf(day: 2, month: 8, year: 2_022)!
        let endDate = Date.beginningOf(day: 10, month: 8, year: 2_022)!
        let store = TestStore(initialState: .init(challengeRange: startDate ... endDate), reducer: UserChallenge())
        store.dependencies.date = .constant(endDate.add(days: 2))
        store.dependencies.challengesClient = .noop
        store.dependencies.challengesClient.challengeByID = { _ in
            store.state.userChallenge.challenge
        }

        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 9,
                dateComponents: self.expectedComponents(for: startDate, index: 9, now: store.dependencies.date.now)
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        await store.send(.failedTapped) {
            $0.userChallenge.answers[9] = .failed
            $0.answerState = .pending(
                pendingIndex: 8,
                dateComponents: self.expectedComponents(for: startDate, index: 8, now: store.dependencies.date.now)
            )
        }

        await store.send(.failedTapped) {
            $0.userChallenge.answers[8] = .failed
            $0.answerState = .answered
        }

        await store.send(.failedTapped)
    }

    func testAnsweringBeyondTheEndDateOfADailyChallengeWithAlreadyAnsweredDays() async throws {
        let startDate = Date.beginningOf(day: 2, month: 8, year: 2_022)!
        let endDate = Date.beginningOf(day: 10, month: 8, year: 2_022)!
        let store = TestStore(
            initialState: .init(challengeRange: startDate ... endDate, answers: [8: .succeeded]),
            reducer: UserChallenge()
        )
        store.dependencies.date = .constant(endDate.add(days: 1))
        store.dependencies.challengesClient = .noop
        store.dependencies.challengesClient.challengeByID = { _ in
            store.state.userChallenge.challenge
        }

        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 9,
                dateComponents: self.expectedComponents(for: startDate, index: 9, now: store.dependencies.date.now)
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        await store.send(.succeededTapped) {
            $0.userChallenge.answers[9] = .succeeded
            $0.answerState = .pending(
                pendingIndex: 7,
                dateComponents: self.expectedComponents(for: startDate, index: 7, now: store.dependencies.date.now)
            )
        }

        await store.send(.succeededTapped) {
            $0.userChallenge.answers[7] = .succeeded
            $0.answerState = .answered
        }

        await store.send(.succeededTapped)
    }

    func testAnsweringBeyondTheEndDateOfADailyChallengeWithoutAnswering() async throws {
        let startDate = Date.beginningOf(day: 2, month: 8, year: 2_022)!
        let endDate = Date.beginningOf(day: 10, month: 8, year: 2_022)!
        let store = TestStore(initialState: .init(challengeRange: startDate ... endDate), reducer: UserChallenge()) {
            $0.date = .constant(endDate.add(days: 1))
        }

        store.dependencies.challengesClient.challengeByID = { _ in
            store.state.userChallenge.challenge
        }

        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 9,
                dateComponents: self.expectedComponents(for: startDate, index: 9, now: store.dependencies.date.now)
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        store.dependencies.date = .constant(endDate.add(days: 2))

        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 9,
                dateComponents: self.expectedComponents(for: startDate, index: 9, now: store.dependencies.date.now)
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        store.dependencies.date = .constant(endDate.add(days: 3))

        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 9,
                dateComponents: self.expectedComponents(for: startDate, index: 9, now: store.dependencies.date.now)
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        store.dependencies.date = .constant(endDate.add(days: 4))

        await store.send(.fetch) {
            $0.answerState = .expired
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))
    }

    func testExpiredChallenge() async throws {
        let startDate = Date.beginningOf(day: 2, month: 8, year: 2_022)!
        let endDate = Date.beginningOf(day: 10, month: 8, year: 2_022)!
        let store = TestStore(initialState: .init(challengeRange: startDate ... endDate), reducer: UserChallenge())
        store.dependencies.date = .constant(endDate.add(days: 4))
        store.dependencies.challengesClient = .noop
        store.dependencies.challengesClient.challengeByID = { _ in
            store.state.userChallenge.challenge
        }

        await store.send(.fetch) {
            $0.answerState = .expired
        }
        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        store.dependencies.date = .constant(endDate.add(days: 5))
        await store.send(.fetch)
        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))
        await store.send(.succeededTapped)
        store.dependencies.date = .constant(endDate.add(days: 6))
        await store.send(.fetch)
        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))
        await store.send(.failedTapped)
    }

    func testLeavingAChallenge() async throws {
        let joinedChallenge = JoinedChallenge.fake(challenge: .fake(title: .word()))
        let store = TestStore(
            initialState: .init(userChallenge: joinedChallenge),
            reducer: UserChallenge()
        )

        await store.send(.leaveTapped) {
            $0.alertState = .leave(challengeTitle: joinedChallenge.challenge.title)
        }

        await store.send(.dismissAlert) {
            $0.alertState = nil
        }

        await store.send(.leaveTapped) {
            $0.alertState = .leave(challengeTitle: joinedChallenge.challenge.title)
        }

        let removedChallengeID = ActorIsolated<Challenge.ID?>(nil)
        store.dependencies.challengesClient.leaveChallenge = { id in
            await removedChallengeID.setValue(id)
            return joinedChallenge.challenge
        }

        await store.send(.leaveConfirmationTapped)

        await store.receive(.leaveChallengeResponse(.success(joinedChallenge.challenge)))

        await removedChallengeID.withValue { XCTAssertEqual(joinedChallenge.id, $0) }
    }

    func testAnsweringAChallengeWillUpdateTheClient() async throws {
        let now = Date()
        let joinedChallenge: JoinedChallenge = .fake(challenge: .init(startDate: now, endDate: now.add(days: 7)))
        let store = TestStore(initialState: .init(challenge: joinedChallenge), reducer: UserChallenge())
        let updatedChallenge = ActorIsolated<JoinedChallenge?>(nil)
        store.dependencies.date = .constant(now)
        store.dependencies.challengesClient.updateJoinedChallenge = { await updatedChallenge.setValue($0) }
        store.dependencies.challengesClient.challengeByID = { _ in
            store.state.userChallenge.challenge
        }

        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 1,
                dateComponents: self.expectedComponents(for: joinedChallenge.challenge.startDate, index: 1, now: now)
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        await updatedChallenge.withValue { XCTAssertNil($0) }

        await store.send(.succeededTapped) {
            $0.answerState = .answered
            $0.userChallenge.answers[1] = .succeeded
        }

        await updatedChallenge.withValue {
            XCTAssertEqual(with(joinedChallenge, concat(
                set(\.answers, [1: .succeeded])
            )), $0)
        }

        store.dependencies.date = .constant(now.add(days: 1))

        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 2,
                dateComponents: self.expectedComponents(
                    for: joinedChallenge.challenge.startDate,
                    index: 2,
                    now: store.dependencies.date.now
                )
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        await store.send(.failedTapped) {
            $0.answerState = .answered
            $0.userChallenge.answers[2] = .failed
        }

        await updatedChallenge.withValue {
            XCTAssertEqual(with(joinedChallenge, concat(
                set(\.answers, [1: .succeeded, 2: .failed])
            )), $0)
        }
    }

    func testCompletedChallenges() async throws {
        let joinedChallenge: JoinedChallenge = .init(
            challenge: .init(
                type: .steps(1),
                interval: .daily,
                startDate: .momentOn(day: 15, month: 8, year: 2_022),
                endDate: .momentOn(day: 15, month: 8, year: 2_022)
            ),
            answers: [1: .succeeded]
        )
        let store = TestStore(
            initialState: .init(userChallenge: joinedChallenge, answerState: .upcoming(.init())),
            reducer: UserChallenge()
        ) {
            $0.challengesClient.challengeByID = { _ in
                joinedChallenge.challenge
            }
        }

        await store.send(.fetch) {
            $0.answerState = .answered
        }

        await store.receive(.updateChallengeResult(.success(joinedChallenge.challenge)))
    }

    func testFetchingAnAnsweredInCompleteChallengeOnTheLastDay() async throws {
        let answers: [Int: JoinedChallenge.Answer] = (2 ... 6).reduce(into: [:]) { ans, idx in
            ans[idx] = .succeeded
        }
        let joinedChallenge: JoinedChallenge = .init(
            challenge: .init(
                type: .steps(1),
                interval: .daily,
                startDate: .momentOn(day: 25, month: 11, year: 2_022),
                endDate: .momentOn(day: 30, month: 11, year: 2_022)
            ),
            answers: answers
        )
        let store = TestStore(
            initialState: .init(userChallenge: joinedChallenge, answerState: .upcoming(.init())),
            reducer: UserChallenge()
        ) {
            $0.date = .constant(.momentOn(day: 30, month: 11, year: 2_022))
            $0.challengesClient.challengeByID = { _ in
                joinedChallenge.challenge
            }
        }

        await store.send(.fetch) {
            $0.answerState = .answered
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))
    }

    func testFetchingAnAnsweredInCompleteChallengeOnTheLastDayWithAPendingUnAnsweredChallenge() async throws {
        let answers: [Int: JoinedChallenge.Answer] = [2: .succeeded, 3: .succeeded, 5: .succeeded, 6: .succeeded]
        let startDate = Date.momentOn(day: 25, month: 11, year: 2_022)
        let endDate = Date.momentOn(day: 30, month: 11, year: 2_022)
        let joinedChallenge: JoinedChallenge = .init(
            challenge: .init(
                type: .steps(1),
                interval: .daily,
                startDate: startDate,
                endDate: endDate
            ),
            answers: answers
        )
        let store = TestStore(
            initialState: .init(userChallenge: joinedChallenge, answerState: .upcoming(.init())),
            reducer: UserChallenge()
        ) {
            $0.date = .constant(endDate)
            $0.challengesClient.challengeByID = { _ in
                joinedChallenge.challenge
            }
        }

        await store.send(.fetch) {
            $0.answerState = .pending(
                pendingIndex: 4,
                dateComponents: DateComponents(day: -2)
            )
        }

        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))
    }

    func testAnsweringWeeklyChallenges() async throws {
        let startDate = Date.beginningOf(day: 1, month: 1, year: 2_023)!
        let endDate = Date.beginningOf(day: 31, month: 1, year: 2_023)!
        let store = TestStore(
            initialState: .init(challengeRange: startDate ... endDate, interval: .weekly),
            reducer: UserChallenge()
        ) {
            $0.challengesClient = .noop
        }

        store.dependencies.challengesClient.challengeByID = { _ in
            store.state.userChallenge.challenge
        }

        // upcoming before start of the challenge
        for day in -10 ... -1 {
            store.dependencies.date = .constant(startDate.add(days: day))
            await store.send(.fetch) {
                $0.answerState = .upcoming(DateComponents(day: -day))
            }
            await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))
        }

        store.dependencies.date = .constant(startDate)
        await store.send(.fetch) {
            $0.answerState = .pendingWeekly(pendingIndex: 1, currentWeekIndex: 1)
        }
        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))
        // answering in the following week does nothing
        for day in 1 ... 6 {
            store.dependencies.date = .constant(startDate.add(days: day))
            await store.send(.fetch)
            await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))
        }

        // next week
        store.dependencies.date = .constant(startDate.add(days: 7))
        await store.send(.fetch) {
            $0.answerState = .pendingWeekly(pendingIndex: 2, currentWeekIndex: 2)
        }
        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        await store.send(.succeededTapped) {
            $0.answerState = .pendingWeekly(pendingIndex: 1, currentWeekIndex: 2)
            $0.userChallenge.answers[2] = .succeeded
        }

        // no change in fetch on next three days
        for day in 7 ... 9 {
            store.dependencies.date = .constant(startDate.add(days: day))
            await store.send(.fetch)
            await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))
        }

        // after three days in the following week it is expired
        store.dependencies.date = .constant(startDate.add(days: 10))
        await store.send(.fetch) {
            $0.answerState = .answered
        }
        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        await store.send(.failedTapped)
        await store.send(.succeededTapped)

        // move forward to 3rd week
        store.dependencies.date = .constant(startDate.add(weeks: 2))
        await store.send(.fetch) {
            $0.answerState = .pendingWeekly(pendingIndex: 3, currentWeekIndex: 3)
        }
        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        await store.send(.succeededTapped) {
            $0.answerState = .answered
            $0.userChallenge.answers[3] = .succeeded
        }

        store.dependencies.date = .constant(startDate.add(weeks: 3))
        await store.send(.fetch) {
            $0.answerState = .pendingWeekly(pendingIndex: 4, currentWeekIndex: 4)
        }
        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))

        store.dependencies.date = .constant(endDate.add(days: 4))
        await store.send(.fetch) {
            $0.answerState = .expired
        }
        await store.receive(.updateChallengeResult(.success(store.state.userChallenge.challenge)))
    }

    func testFetchingGroupChallengeUpdatesUserProgresses() async throws {
        let startDate = Date.momentOn(day: 25, month: 11, year: 2_022)
        let endDate = Date.momentOn(day: 30, month: 11, year: 2_022)
        let challenge = Challenge(
            type: .steps(1),
            interval: .daily,
            startDate: startDate,
            endDate: endDate,
            kind: .group([])
        )
        let joinedChallenge: JoinedChallenge = .init(
            challenge: challenge,
            answers: [:]
        )
        let userProgresses = [
            UserProgress(totalAnswers: 5, succeededAnswers: 3, user: .fake()),
            UserProgress(totalAnswers: 3, succeededAnswers: 2, user: .fake()),
            UserProgress(totalAnswers: 7, succeededAnswers: 1, user: .fake())
        ]
        let fetchedChallenge = with(challenge, concat(
            set(\.kind, .group(userProgresses))
        ))

        let store = TestStore(
            initialState: .init(userChallenge: joinedChallenge, answerState: .upcoming(.init())),
            reducer: UserChallenge()
        ) {
            $0.date = .constant(startDate.add(days: -1))
            $0.challengesClient.challengeByID = { _ in
                fetchedChallenge
            }
        }

        await store.send(.fetch) {
            $0.answerState = .upcoming(DateComponents(day: 1))
        }

        await store.receive(.updateChallengeResult(.success(fetchedChallenge))) {
            $0.userChallenge.challenge = fetchedChallenge
            $0.progressesState = .init(userProgresses: userProgresses, maxAllowedAnswers: 6)
        }

        let userId = userProgresses.randomElement()!.user.id
        await store.send(.userProgresses(.userResult(userId))) {
            $0.progressesState?.status = .content(.init(uniqueElements: userProgresses.filter { $0.user.id != userId }))
        }
    }
}

//
//  Created by Kumpels and Friends on 01.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Overture
import QuizFeature
import XCTest
import XCTestDynamicOverlay

extension QuizState {
    func success(on date: Date) -> Self {
        .init(
            quiz: quiz,
            streak: streak + 1,
            answer: .init(date: date, choice: quiz.correctAnswer),
            maxSuccessStreak: maxSuccessStreak + 1,
            currentSuccessStreak: currentSuccessStreak + 1
        )
    }

    func failure(on date: Date, choice: Quiz.Choice) -> Self {
        .init(
            quiz: quiz,
            streak: streak + 1,
            answer: .init(date: date, choice: choice),
            maxSuccessStreak: maxSuccessStreak,
            currentSuccessStreak: 0
        )
    }
}

@MainActor
final class QuizFeatureTests: XCTestCase {
    func testLoadingAQuizFromClient() async {
        let date: Date = .now
        let quizState = QuizState(quiz: .fake(), streak: 10, answer: nil)
        let store = TestStore(
            initialState: .init(quizState: nil),
            reducer: QuizFeature()
        )
        store.dependencies.calendar = .current
        store.dependencies.date = .constant(date)
        store.dependencies.quizClient.loadState = { quizState }

        await store.send(.load) {
            $0.isLoading = true
        }

        await store.receive(.loadResponse(.success(quizState))) {
            $0.quizState = quizState
            $0.isLoading = false
        }
    }

    func testFlowWithCorrectAnswer() async throws {
        let answeredState = ActorIsolated<QuizState?>(nil)
        let date = Date.now
        let state = QuizState(quiz: .fake(correctAnswer: .a), streak: 10, answer: .init(date: date, choice: .a))
        let quizState = ActorIsolated(state)
        let store = TestStore(
            initialState: .init(quizState: state),
            reducer: QuizFeature()
        ) {
            $0.date = .constant(date.add(days: 1))
            $0.calendar = .current
            $0.quizClient.loadState = { await quizState.value }
            $0.quizClient.saveState = { await answeredState.setValue($0) }
        }

        await store.send(.setNavigation(isActive: true)) {
            $0.quizAnswering = state
        }

        await store.send(.quizAnswer(.answerTapped(state.quiz.correctAnswer))) {
            $0.quizAnswering?.answer = .init(date: date.add(days: 1), choice: state.quiz.correctAnswer)
            $0.quizAnswering?.streak = 11
            $0.quizAnswering?.maxSuccessStreak = 1
            $0.quizAnswering?.currentSuccessStreak = 1
        }

        await answeredState.withValue { [date = date.add(days: 1)] answeredState in
            XCTAssertNoDifference(state.success(on: date), answeredState)
        }

        await quizState.setValue(state.success(on: date.add(days: 1)))

        // answering multiple times on same day will not change the state
        await answeredState.setValue(nil)

        await store.send(.quizAnswer(.answerTapped(quizState.quiz.correctAnswer)))

        await answeredState.withValue { answeredState in
            XCTAssertNil(answeredState)
        }

        await store.send(.setNavigation(isActive: false)) {
            $0.quizState = $0.quizAnswering
            $0.quizAnswering = nil
        }

        await store.send(.load) {
            $0.isLoading = true
        }

        let expected = await quizState.value
        await store.receive(.loadResponse(.success(expected))) {
            $0.quizState = expected
            $0.isLoading = false
        }

        store.dependencies.date = .constant(date.add(days: 2))

        await store.send(.load) {
            $0.isLoading = true
        }

        await store.receive(.loadResponse(.success(expected))) {
            $0.quizState = expected
            $0.isLoading = false
        }

        await store.send(.setNavigation(isActive: true)) {
            $0.quizAnswering = expected
        }

        await store.send(.quizAnswer(.answerTapped(expected.quiz.correctAnswer))) {
            $0.quizAnswering?.answer = .init(date: date.add(days: 2), choice: expected.quiz.correctAnswer)
            $0.quizAnswering?.streak = 12
            $0.quizAnswering?.maxSuccessStreak = 2
            $0.quizAnswering?.currentSuccessStreak = 2
        }

        await answeredState.withValue { [date = date.add(days: 2)] answeredState in
            XCTAssertNoDifference(
                expected.success(on: date),
                answeredState
            )
        }

        await quizState.setValue(expected.success(on: date.add(days: 2)))

        await store.send(.setNavigation(isActive: false)) {
            $0.quizState = $0.quizAnswering
            $0.quizAnswering = nil
        }

        await store.send(.load) {
            $0.isLoading = true
        }

        let currentState = await quizState.value
        await store.receive(.loadResponse(.success(currentState))) {
            $0.quizState = currentState
            $0.isLoading = false
        }
    }

    func testFlowWithInvalidAnswer() async throws {
        let answeredState = ActorIsolated<QuizState?>(nil)
        let date: Date = .now
        let state = QuizState(
            quiz: .fake(),
            streak: Int.random(in: 1 ... 100),
            answer: nil
        )
        let quizState = ActorIsolated(state)
        let store = TestStore(
            initialState: .init(quizState: state),
            reducer: QuizFeature()
        ) {
            $0.date = .constant(date)
            $0.calendar = .current
            $0.quizClient.loadState = { await quizState.value }
            $0.quizClient.saveState = { await answeredState.setValue($0) }
        }

        let incorrectAnswers = Quiz.Choice.allCases.filter { $0 != state.quiz.correctAnswer }
        let answer = incorrectAnswers.randomElement()!

        await store.send(.setNavigation(isActive: true)) {
            $0.quizAnswering = state
        }

        await store.send(.quizAnswer(.answerTapped(answer))) {
            $0.quizAnswering?.answer = .init(date: date, choice: answer)
            $0.quizAnswering?.streak += 1
            $0.quizAnswering?.currentSuccessStreak = 0
        }

        await answeredState.withValue { [date = date] answeredState in
            XCTAssertNoDifference(state.failure(on: date, choice: answer), answeredState)
        }

        await quizState.setValue(state.failure(on: date, choice: answer))

        // answering multiple times on same day will not change the state
        await answeredState.setValue(nil)
        await store.send(.quizAnswer(.answerTapped(incorrectAnswers.randomElement()!)))

        await store.send(.setNavigation(isActive: false)) {
            $0.quizState = $0.quizAnswering
            $0.quizAnswering = nil
        }

        await answeredState.withValue { XCTAssertNil($0) }
        await store.send(.load) {
            $0.isLoading = true
        }

        let expected = await quizState.value
        await store.receive(.loadResponse(.success(expected))) {
            $0.quizState = expected
            $0.isLoading = false
        }

        store.dependencies.date = .constant(date.add(days: 1))

        await store.send(.load) {
            $0.isLoading = true
        }

        await store.receive(.loadResponse(.success(expected))) {
            $0.quizState = expected
            $0.isLoading = false
        }

        await store.send(.setNavigation(isActive: true)) {
            $0.quizAnswering = expected
        }

        let newAnswer = Quiz.Choice.allCases.filter { $0 != expected.quiz.correctAnswer }.randomElement()!
        await store.send(.quizAnswer(.answerTapped(newAnswer))) {
            $0.quizAnswering?.answer = .init(date: date.add(days: 1), choice: newAnswer)
            $0.quizAnswering?.streak += 1
            $0.quizAnswering?.currentSuccessStreak = 0
        }

        await answeredState.withValue { [date = date.add(days: 1)] answeredState in
            XCTAssertNoDifference(expected.failure(on: date, choice: newAnswer), answeredState)
        }
    }

    func testNotAnsweringForADayWillResetTheStreak() async {
        let answeredState = ActorIsolated<QuizState?>(nil)
        var date: Date = .now
        // yesterdays state
        let quizState = QuizState(
            quiz: .fake(),
            streak: Int.random(in: 1 ... 100),
            answer: .init(date: date.add(days: -1), choice: Quiz.Choice.allCases.randomElement()!)
        )
        let store = TestStore(
            initialState: .init(quizState: quizState),
            reducer: QuizFeature()
        ) {
            $0.date = .constant(date)
            $0.calendar = .current
            $0.quizClient.loadState = { quizState }
            $0.quizClient.saveState = { await answeredState.setValue($0) }
        }

        await store.send(.load) {
            $0.isLoading = true
        }

        await store.receive(.loadResponse(.success(quizState))) {
            $0.quizState = quizState
            $0.isLoading = false
        }

        // tomorrow
        date = date.add(days: 1)
        store.dependencies.date = .constant(date)

        await store.send(.load) {
            $0.isLoading = true
        }

        await store.receive(.loadResponse(.success(quizState))) {
            $0.quizState = quizState
            $0.isLoading = false
        }

        await answeredState.withValue { answeredState in
            XCTAssertEqual(0, answeredState?.streak)
        }
    }
}

extension DateGenerator {
    mutating func advanceDate(by days: Int) {
        let current = self()
        self = .constant(current.add(days: days))
    }
}

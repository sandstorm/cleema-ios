//
//  Created by Kumpels and Friends on 02.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models
import SurveysFeature
import XCTest

@MainActor
final class SurveysFeatureTests: XCTestCase {
    func testParticipationFlow() async {
        let surveys: [Survey] = [.fake(), .fake()]

        let store = TestStore(initialState: .init(userAcceptedSurveys: true), reducer: Surveys()) {
            $0.surveysClient.surveys = { surveys }
            $0.surveysClient.participate = { id in surveys.first { $0.id == id }! }
        }

        await store.send(.task)

        await store.receive(.loadResponse(.success(surveys))) {
            $0.surveys = .init(uniqueElements: surveys)
        }

        let tappedSurvey = surveys.randomElement()!
        await store.send(.survey(tappedSurvey.id, .participateTapped))

        await store.receive(.survey(tappedSurvey.id, .taskResponse(.success(tappedSurvey)))) {
            $0.surveys = .init(uniqueElements: surveys.filter { $0.id != tappedSurvey.id })
        }
    }

    func testEvaluationFlow() async {
        let evaluationURL = URL(string: "http://localhost")!
        let surveys: [Survey] = [.fake(state: .evaluation(evaluationURL)), .fake(state: .evaluation(evaluationURL))]

        let store = TestStore(initialState: .init(userAcceptedSurveys: true), reducer: Surveys()) {
            $0.surveysClient.surveys = { surveys }
            $0.surveysClient.evaluate = { id in surveys.first { $0.id == id }! }
        }

        await store.send(.task)

        await store.receive(.loadResponse(.success(surveys))) {
            $0.surveys = .init(uniqueElements: surveys)
        }

        let tappedSurvey = surveys.randomElement()!
        await store.send(.survey(tappedSurvey.id, .evaluationTapped))

        await store.receive(.survey(tappedSurvey.id, .taskResponse(.success(tappedSurvey)))) {
            $0.surveys = .init(uniqueElements: surveys.filter { $0.id != tappedSurvey.id })
        }
    }

    func testUserDidNotAcceptSurveys() async {
        let store = TestStore(initialState: .init(userAcceptedSurveys: false), reducer: Surveys())

        await store.send(.task)
    }
}

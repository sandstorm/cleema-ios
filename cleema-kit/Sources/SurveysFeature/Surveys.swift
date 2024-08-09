//
//  Created by Kumpels and Friends on 02.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Logging
import Models
import SurveysClient

public struct Surveys: ReducerProtocol {
    public struct State: Equatable {
        public var userAcceptedSurveys: Bool
        public var surveys: IdentifiedArrayOf<Survey>
        public init(
            userAcceptedSurveys: Bool = false,
            surveys: IdentifiedArrayOf<Survey> = []
        ) {
            self.userAcceptedSurveys = userAcceptedSurveys
            self.surveys = surveys
        }

        public var showsSurveys: Bool {
            userAcceptedSurveys && !surveys.isEmpty
        }
    }

    public enum Action: Equatable {
        case task
        case loadResponse(TaskResult<[Survey]>)
        case survey(Survey.ID, SurveyFeature.Action)
    }

    @Dependency(\.surveysClient.surveys) private var surveys
    @Dependency(\.log) private var log

    public init() {}

    public var body: some ReducerProtocolOf<Surveys> {
        Reduce { state, action in
            enum CancelID {}

            switch action {
            case .task:
                guard state.userAcceptedSurveys else { return .none }
                return .task {
                    await .loadResponse(
                        TaskResult {
                            try await surveys()
                        }
                    )
                }
                .cancellable(id: CancelID.self)
            case let .loadResponse(.success(surveys)):
                state.surveys = .init(uniqueElements: surveys)
                return .none
            case let .loadResponse(.failure(error)):
                return .fireAndForget {
                    log.error("Error loading surveys.", userInfo: error.logInfo)
                }
            case let .survey(_, .taskResponse(.success(survey))):
                var surveys = state.surveys
                surveys.remove(id: survey.id)
                state.surveys = surveys
                return .none
            case .survey:
                return .none
            }
        }
        .forEach(\.surveys, action: /Action.survey) {
            SurveyFeature()
        }
    }
}

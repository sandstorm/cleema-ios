//
//  Created by Kumpels and Friends on 02.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Logging
import Models
import UIKit

public struct SurveyFeature: ReducerProtocol {
    public typealias State = Survey

    public enum Action: Equatable {
        case participateTapped
        case evaluationTapped
        case taskResponse(TaskResult<Survey>)
    }

    @Dependency(\.surveysClient.participate) private var participate
    @Dependency(\.surveysClient.evaluate) private var evaluate
    @Dependency(\.log) private var log

    public init() {}

    public var body: some ReducerProtocolOf<SurveyFeature> {
        Reduce { state, action in
            switch action {
            case .participateTapped:
                guard case let .participation(url) = state.state else { return .none }
                return .concatenate(
                    .task { [id = state.id] in
                        await .taskResponse(TaskResult { try await participate(id) })
                    },
                    .fireAndForget {
                        UIApplication.shared.open(url)
                    }
                )
            case .evaluationTapped:
                guard case let .evaluation(url) = state.state else { return .none }
                return .concatenate(
                    .task { [id = state.id] in
                        await .taskResponse(TaskResult { try await evaluate(id) })
                    },
                    .fireAndForget {
                        UIApplication.shared.open(url)
                    }
                )
            case let .taskResponse(.success(survey)):
                state = survey
                return .none
            case let .taskResponse(.failure(error)):
                return .fireAndForget {
                    log.error("Error participating/evaluating survey.", userInfo: error.logInfo)
                }
            }
        }
    }
}

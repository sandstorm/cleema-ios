//
//  Created by Kumpels and Friends on 21.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Logging
import Models
import Overture
import QuizClient
import SwiftUI

public struct QuizFeature: ReducerProtocol {
    public struct State: Equatable {
        public enum AnswerState: Equatable {
            case pending
            case answered
        }

        public var quizState: QuizState?
        public var isLoading: Bool
        public var quizAnswering: QuizState?
        public var region: Region.ID?

        public init(
            quizState: QuizState? = nil,
            isLoading: Bool = false,
            quizAnswering: QuizAnswering.State? = nil,
            region: Region.ID? = nil
        ) {
            self.quizState = quizState
            self.isLoading = isLoading
            self.quizAnswering = quizAnswering
            self.region = region
        }

        var showsAnswers: Bool {
            quizAnswering != nil
        }
    }

    public enum Action: Equatable {
        case load
        case loadResponse(TaskResult<QuizState>)
        case setNavigation(isActive: Bool)
        case quizAnswer(QuizAnswering.Action)
    }

    @Dependency(\.date.now) var now
    @Dependency(\.quizClient.loadState) var loadState
    @Dependency(\.quizClient.saveState) var saveState
    @Dependency(\.calendar) var calendar
    @Dependency(\.log) var log

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                state.isLoading = true
                return .task { [region = state.region] in
                    await .loadResponse(
                        TaskResult { try await loadState(region) }
                    )
                }
                .animation(.default)
            case let .loadResponse(.success(quizResponse)):
                state.quizState = quizResponse
                state.isLoading = false
                guard let answer = quizResponse.answer else {
                    return .none
                }
                if answer.date.numberOfDays(to: now) >= 1 {
                    return .fireAndForget {
                        try await saveState(with(quizResponse, set(\.streak, 0)))
                    }
                }
                return .none
            case let .loadResponse(.failure(error)):
                state.isLoading = false
                return .fireAndForget {
                    log.error("Error loading quiz", userInfo: error.logInfo)
                }
            case .setNavigation(isActive: true):
                guard let quizState = state.quizState else { return .none }
                state.quizAnswering = quizState
                return .none
            case .setNavigation(isActive: false):
                guard let answer = state.quizAnswering else { return .none }
                state.quizState = answer
                state.quizAnswering = nil
                return .none
            case .quizAnswer:
                return .none
            }
        }
        .ifLet(\.quizAnswering, action: /Action.quizAnswer) {
            QuizAnswering()
        }
    }
}

extension QuizState {
    var answerState: QuizFeature.State.AnswerState {
        answer == nil ? .pending : .answered
    }
}

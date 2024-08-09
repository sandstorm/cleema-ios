//
//  Created by Kumpels and Friends on 30.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Logging
import Models

public struct PartnerChallenge: ReducerProtocol {
    public struct State: Equatable {
        public var challenge: Challenge
        public var isLoading: Bool = false

        public init(challenge: Challenge, isLoading: Bool = false) {
            self.challenge = challenge
            self.isLoading = isLoading
        }
    }

    public enum Action: Equatable {
        case joinLeaveButtonTapped
        case joinResult(TaskResult<Challenge>)
        case leaveResult(TaskResult<Challenge>)
    }

    @Dependency(\.challengesClient.joinPartnerChallenge) private var joinChallenge
    @Dependency(\.challengesClient.leaveChallenge) private var leaveChallenge
    @Dependency(\.log) private var log

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .joinLeaveButtonTapped:
            state.isLoading = true
            return .task { [id = state.challenge.id, isJoined = state.challenge.isJoined] in
                if isJoined {
                    return await .leaveResult(TaskResult {
                        try await leaveChallenge(id)
                    })
                } else {
                    return await .joinResult(TaskResult {
                        try await joinChallenge(id)
                    })
                }
            }
        case let .joinResult(.success(challenge)),
             let .leaveResult(.success(challenge)):
            state.isLoading = false
            state.challenge = challenge
            return .none
        case let .joinResult(.failure(error)):
            state.isLoading = false
            return .fireAndForget {
                log.error("Error joining challenge", userInfo: error.logInfo)
            }
        case let .leaveResult(.failure(error)):
            state.isLoading = false
            return .fireAndForget {
                log.error("Error leaving challenge", userInfo: error.logInfo)
            }
        }
    }
}

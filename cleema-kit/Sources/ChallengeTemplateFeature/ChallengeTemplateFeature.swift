//
//  Created by Kumpels and Friends on 23.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ChallengesClient
import ComposableArchitecture
import EditChallengeFeature
import Foundation
import Logging
import Models
import SwiftUI

public struct ChallengeTemplates: ReducerProtocol {
    public struct State: Equatable {
        public var challenges: IdentifiedArrayOf<Challenge>
        public var userRegion: Region
        public var editState: Identified<EditChallenge.State.ID, EditChallenge.State>?

        public init(
            challenges: IdentifiedArrayOf<Challenge> = [],
            userRegion: Region,
            editState: Identified<Challenge.ID, EditChallenge.State>? = nil
        ) {
            self.challenges = challenges
            self.userRegion = userRegion
            self.editState = editState
        }
    }

    public enum Action: Equatable {
        case load
        case challengeResponse(TaskResult<[Challenge]>)
        case edit(EditChallenge.Action)
        case challengeTapped(id: Challenge.ID?)
        case closeEditSheet
        case cancelTapped
        case saveResponse(TaskResult<Challenge>)
    }

    @Dependency(\.challengesClient.fetchTemplates) private var fetchTemplates
    @Dependency(\.challengesClient.save) private var save
    @Dependency(\.challengeID) public var challengeID
    @Dependency(\.log) var log

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .load:
                return .task {
                    await .challengeResponse(TaskResult { try await fetchTemplates() })
                }
            case let .challengeResponse(.success(challenges)):
                state.challenges = .init(uniqueElements: challenges)
                return .none
            case let .challengeResponse(.failure(error)):
                return .fireAndForget {
                    log.error("Error fetching templates", userInfo: error.logInfo)
                }
            case .edit(.commitChanges):
                guard var edited = state.editState else { return .none }
                edited.challenge.title = edited.challenge.title.trimmingCharacters(in: .whitespacesAndNewlines)
                edited.challenge.description = edited.challenge.description
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                edited.challenge.region = state.userRegion

                // Here
                return .task { [edited] in
                    await .saveResponse(TaskResult {
                        try await save(edited.challenge, edited.inviteUsersToChallengeState?.selectedFollowers ?? [])
                    })
                }
            case .saveResponse(.success):
                return .task { .closeEditSheet }
                    .animation(.default)
            case let .saveResponse(.failure(error)):
                // TODO: handle errors
                return .fireAndForget {
                    log.error("Error saving challenge", userInfo: error.logInfo)
                }
            case let .challengeTapped(id?):
                guard var challenge = state.challenges[id: id] else { return .none }
                challenge.id = challengeID()
                state.editState = .init(.init(challenge: challenge), id: id)
                return .none
            case .challengeTapped(nil), .closeEditSheet:
                state.editState = nil
                return .none
            case .cancelTapped:
                state.editState = nil
                return .none
            case .edit(.cancelButtonTapped):
                return .task { .cancelTapped }
            case .edit: return .none
            }
        }
        .ifLet(\.editState, action: /Action.edit) {
            Scope(state: \Identified.value, action: /.self) {
                EditChallenge()
            }
        }
    }
}

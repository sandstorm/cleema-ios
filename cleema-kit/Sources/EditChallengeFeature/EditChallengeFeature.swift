//
//  Created by Kumpels and Friends on 25.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import InviteUsersToChallengeFeature
import Models
import UserClient

public struct EditChallenge: ReducerProtocol {
    public enum Selection: String, Identifiable {
        case steps
        case measurement

        public var id: Self { self }
    }

    public struct State: Equatable, Identifiable {
        public var id: Challenge.ID {
            challenge.id
        }

        @BindingState
        public var challenge: Challenge
        @BindingState
        public var selection: Selection
        public var progressState: ProgressCounter.State {
            didSet {
                challenge.type = .steps(progressState.count)
            }
        }

        public var measurementState: MeasurementGoal.State {
            didSet {
                challenge.type = .measurement(measurementState.count, measurementState.unit)
            }
        }

        public var inviteUsersToChallengeState: InviteUsersToChallenge.State?
        public var isComplete: Bool
        public var shouldEndEditing: Bool
        public var canInviteFriends: Bool

        public init(challenge: Challenge, canInviteFriends: Bool = false) {
            self.challenge = challenge
            switch challenge.type {
            case .steps:
                selection = .steps
            case .measurement:
                selection = .measurement
            }
            progressState = .init(count: challenge.type.count)
            measurementState = .init(count: challenge.type.count, unit: challenge.type.unit)
            isComplete = !(challenge.title.isEmpty || challenge.description.isEmpty)
            shouldEndEditing = false
            self.canInviteFriends = canInviteFriends
        }
    }

    public enum Action: Equatable, BindableAction {
        case progress(ProgressCounter.Action)
        case measurement(MeasurementGoal.Action)
        case binding(BindingAction<EditChallenge.State>)
        case nextButtonTapped
        case cancelButtonTapped
        case setNavigation(isActive: Bool)
        case commitChanges
        case inviteUsersToChallenge(InviteUsersToChallenge.Action)
        case task
        case userResponse(User)
    }

    @Dependency(\.userClient.userStream) private var userStream

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Scope(state: \.progressState, action: /Action.progress) {
            ProgressCounter()
        }

        Scope(state: \.measurementState, action: /Action.measurement) {
            MeasurementGoal()
        }

        Reduce { state, action in
            switch action {
            case .task:
                return Effect.run { send in
                    for await user in userStream().compactMap({ $0?.user }) {
                        await send(.userResponse(user))
                    }
                }
            case let .userResponse(user):
                switch user.kind {
                case .local:
                    state.canInviteFriends = false
                case .remote:
                    state.canInviteFriends = true
                }
                return .none
            case .binding:
                let title = state.challenge.title.trimmingCharacters(in: .whitespacesAndNewlines)
                let description = state.challenge.description.trimmingCharacters(in: .whitespacesAndNewlines)
                state.isComplete = !(title.isEmpty || description.isEmpty)
                let start = state.challenge.startDate
                let end = state.challenge.endDate
                state.challenge.endDate = max(start, end)
                return .none
            case .nextButtonTapped:
                if state.canInviteFriends && state.challenge.isPublic {
                    return .task { .setNavigation(isActive: true) }
                } else {
                    return .task { .commitChanges }
                }
            case .setNavigation(isActive: true):
                state.inviteUsersToChallengeState = .loading
                return .none
            case .setNavigation(isActive: false):
                state.inviteUsersToChallengeState = nil
                return .none
            case .commitChanges:
                state.shouldEndEditing = true
                return .none
            case .cancelButtonTapped:
                return .none
            case .progress:
                return .none
            case .measurement:
                return .none
            case .inviteUsersToChallenge(.cancelButtonTapped):
                return .task { .cancelButtonTapped }
            case .inviteUsersToChallenge(.saveButtonTapped):
                return .task { .commitChanges }
            case .inviteUsersToChallenge:
                return .none
            }
        }
        .ifLet(\.inviteUsersToChallengeState, action: /Action.inviteUsersToChallenge) {
            InviteUsersToChallenge()
        }
    }
}

extension EditChallenge.State {
    var showsInviteUsers: Bool {
        inviteUsersToChallengeState != nil
    }
}

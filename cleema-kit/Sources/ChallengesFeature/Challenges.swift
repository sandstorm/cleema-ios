//
//  Created by Kumpels and Friends on 24.10.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ChallengeTemplateFeature
import ComposableArchitecture
import JoinedChallengesFeature
import PartnerChallengesFeature
import SelectRegionFeature
import SwiftUI
import UserChallengeFeature

public struct Challenges: ReducerProtocol {
    public struct State: Equatable {
        public var joinedChallengesState: JoinedChallengesList.State
        public var challengeTemplatesState: ChallengeTemplates.State?
        public var partnerChallengesState: PartnerChallengeList.State?
        public var selectRegionState: SelectRegion.State
        public var userRegion: Region

        public init(
            selectRegionState: SelectRegion.State,
            joinedChallengesState: JoinedChallengesList.State = .init(),
            challengeTemplatesState: ChallengeTemplates.State? = nil,
            partnerChallengesState: PartnerChallengeList.State? = nil,
            userRegion: Region
        ) {
            self.selectRegionState = selectRegionState
            self.joinedChallengesState = joinedChallengesState
            self.challengeTemplatesState = challengeTemplatesState
            self.partnerChallengesState = partnerChallengesState ?? selectRegionState.selectedRegion
                .map { .init(region: $0) }
                // TODO: this is an ugly hack
                ?? .init(region: .leipzig)
            self.userRegion = userRegion
        }
    }

    public enum Action: Equatable {
        case joinedChallenges(JoinedChallengesList.Action)
        case challengeTemplates(ChallengeTemplates.Action)
        case addChallengeTapped
        case dismissSheet
        case profileButtonTapped
        case partnerChallenges(PartnerChallengeList.Action)
        case selectRegion(SelectRegion.Action)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.joinedChallengesState, action: /Action.joinedChallenges) {
            JoinedChallengesList()
        }

        Scope(state: \.selectRegionState, action: /Action.selectRegion) {
            SelectRegion()
        }

        Reduce { state, action in
            switch action {
            case .addChallengeTapped, .joinedChallenges(.addChallengeTapped):
                state.challengeTemplatesState = .init(userRegion: state.userRegion)
                return .none
            case let .challengeTemplates(.saveResponse(.success(challenge))):
                state.joinedChallengesState.challenges[id: challenge.id] = .init(challenge: challenge)
                return .none
            case .challengeTemplates(.closeEditSheet):
                state.challengeTemplatesState = nil
                return .none
            case .dismissSheet, .challengeTemplates(.cancelTapped):
                state.challengeTemplatesState = nil
                return .none
            case .challengeTemplates, .profileButtonTapped, .partnerChallenges, .joinedChallenges:
                return .none
            case .selectRegion(.binding):
                guard let region = state.selectRegionState.selectedRegion else { return .none }
                return .task { .partnerChallenges(.setRegion(region)) }
            case .selectRegion:
                return .none
            }
        }
        .ifLet(\.challengeTemplatesState, action: /Action.challengeTemplates) {
            ChallengeTemplates()
        }
        .ifLet(\.partnerChallengesState, action: /Action.partnerChallenges) {
            PartnerChallengeList()
        }
    }
}

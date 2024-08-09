//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import BecomePartner
import BecomeSponsor
import ComposableArchitecture
import DashboardGridFeature
import InfoFeature
import JoinedChallengesFeature
import Models
import ProjectDetailFeature
import QuizFeature
import SurveysFeature
import SwiftUI

// MARK: - State

public struct Dashboard: ReducerProtocol {
    public struct State: Equatable {
        public var quizState: QuizFeature.State
        public var surveysState: Surveys.State
        public var gridState: DashboardGrid.State
        public var joinedChallengesState: JoinedChallengesList.State
        public var becomeSponsorState: BecomeSponsor.State?
        public var becomePartnerState: BecomePartner.State?

        public init(
            quizState: QuizFeature.State = .init(),
            surveysState: Surveys.State = .init(),
            gridState: DashboardGrid.State,
            joinedChallengesState: JoinedChallengesList.State = .init(),
            becomeSponsorState: BecomeSponsor.State? = nil,
            becomePartnerState: BecomePartner.State? = nil
        ) {
            self.quizState = quizState
            self.surveysState = surveysState
            self.gridState = gridState
            self.joinedChallengesState = joinedChallengesState
            self.becomeSponsorState = becomeSponsorState
            self.becomePartnerState = becomePartnerState
        }
    }

    public enum Action: Equatable {
        case task
        case load
        case profileButtonTapped
        case infoButtonTapped(InfoDetail.ID)
        case quiz(QuizFeature.Action)
        case surveys(Surveys.Action)
        case grid(DashboardGrid.Action)
        case joinedChallengeList(JoinedChallengesList.Action)
        case becomeSponsor(BecomeSponsor.Action)
        case becomePartner(BecomePartner.Action)
        case dismissSheet
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(
            state: \.quizState,
            action: /Action.quiz
        ) {
            QuizFeature()
        }

        Scope(state: \.surveysState, action: /Action.surveys) {
            Surveys()
        }

        Scope(state: \.joinedChallengesState, action: /Action.joinedChallengeList) {
            JoinedChallengesList()
        }

        Scope(state: \.gridState, action: /Action.grid) {
            DashboardGrid()
        }

        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    let notifications = await NotificationCenter.default
                        .notifications(named: UIApplication.didBecomeActiveNotification)
                    for await _ in notifications {
                        await send(.load)
                        await send(.quiz(.load))
                        await send(.surveys(.task))
                    }
                }
            case .load:
                return .none
            case .profileButtonTapped, .infoButtonTapped:
                return .none
            case .quiz:
                return .none
            case .surveys:
                return .none
            case .grid:
                return .none
            case .joinedChallengeList:
                return .none
            case .dismissSheet, .becomeSponsor(.dismissSheet), .becomePartner(.dismissSheet):
                state.becomeSponsorState = nil
                state.becomePartnerState = nil
                return .none
            case .becomeSponsor, .becomePartner:
                return .none
            }
        }
        .ifLet(\.becomeSponsorState, action: /Action.becomeSponsor, then: BecomeSponsor.init)
        .ifLet(\.becomePartnerState, action: /Action.becomePartner, then: BecomePartner.init)
    }
}

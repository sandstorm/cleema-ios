//
//  Created by Kumpels and Friends on 10.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ChallengesClient
import ComposableArchitecture
import Foundation
import Models
import SwiftUI
import UserClient
import UserProgressesFeature

// FIXME: Is UserChallenge a good name?
public struct UserChallenge: ReducerProtocol {
    public struct State: Equatable {
        public var userChallenge: JoinedChallenge
        public var answerState: AnswerState
        public var alertState: AlertState<UserChallenge.Action>?
        public var progressesState: UserProgresses.State?

        public init(
            userChallenge: JoinedChallenge,
            answerState: AnswerState = .answered,
            alertState: AlertState<UserChallenge.Action>? = nil,
            progressesState: UserProgresses.State? = nil
        ) {
            self.userChallenge = userChallenge
            self.answerState = answerState
            self.alertState = alertState
            self.progressesState = progressesState
        }
    }

    public enum Action: Equatable {
        case succeededTapped
        case failedTapped
        case leaveTapped
        case fetch
        case leaveConfirmationTapped
        case dismissAlert
        case leaveChallengeResponse(TaskResult<Challenge>)
        case userProgresses(UserProgresses.Action)
        case updateChallengeResult(TaskResult<Challenge>)
    }

    @Dependency(\.date.now) public var now
    @Dependency(\.challengesClient.challengeByID) private var challengeByID
    @Dependency(\.challengesClient.updateJoinedChallenge) private var updateJoinedChallenge
    @Dependency(\.challengesClient.leaveChallenge) private var leaveChallenge

    public init() {}

    public var body: some ReducerProtocolOf<UserChallenge> {
        Reduce { state, action in
            switch action {
            case .succeededTapped:
                state.answer(.succeeded, on: now)
                return .fireAndForget { [state] in
                    try await updateJoinedChallenge(state.userChallenge)
                }
            case .failedTapped:
                state.answer(.failed, on: now)
                return .fireAndForget { [state] in
                    try await updateJoinedChallenge(state.userChallenge)
                }
            case .leaveTapped:
                state.alertState = .leave(challengeTitle: state.userChallenge.challenge.title)
                return .none
            case .fetch:
                if state.userChallenge.isComplete {
                    state.answerState = .answered
                } else {
                    state.answerState = state.userChallenge.calculateAnswerState(for: now)
                }
                return .task { [id = state.userChallenge.challenge.id] in
                    .updateChallengeResult(
                        await TaskResult {
                            try await challengeByID(id)
                        }
                    )
                }
            case let .updateChallengeResult(.success(challenge)):
                state.userChallenge.challenge = challenge
                if case let .group(userProgresses) = challenge.kind, !userProgresses.isEmpty {
                    state.progressesState = .init(
                        userProgresses: userProgresses,
                        maxAllowedAnswers: state.userChallenge.duration
                    )
                }
                return .none
            case .updateChallengeResult:
                // TODO: handle error
                return .none
            case .dismissAlert:
                state.alertState = nil
                return .none
            case .leaveConfirmationTapped:
                return .task { [id = state.userChallenge.id] in
                    await .leaveChallengeResponse(TaskResult { try await leaveChallenge(id) })
                }
            case .leaveChallengeResponse(.success(_)):
                return .none
            case .leaveChallengeResponse(.failure(_)):
                // TODO: Handle error
                return .none
            case .userProgresses:
                return .none
            }
        }
        .ifLet(\.progressesState, action: /Action.userProgresses, then: UserProgresses.init)
    }
}

extension JoinedChallenge {
    func calculateAnswerState(for today: Date) -> AnswerState {
        let todayFromStart = challenge.startDate.numberOfDays(to: today.startOfDay)
        if todayFromStart < 0 {
            return AnswerState
                .upcoming(Calendar.current.dateComponents([.day], from: today.startOfDay, to: challenge.startDate))
        }

        if challenge.interval == .daily {
            if todayFromStart > challenge.duration.dayCount + 2 {
                return .expired
            }
            guard let index = challenge.ordinal(for: today) else {
                guard let pendingIndex = previousPendingIndexOrNullWhenDaily(for: challenge.endDate)
                else { return .expired }
                return .pending(
                    pendingIndex: pendingIndex,
                    dateComponents: .components(for: challenge.startDate, index: pendingIndex, now: today)
                )
            }
            if answers[index] != nil {
                guard let pendingIndex = previousPendingIndexOrNullWhenDaily(for: today) else { return .answered }
                return .pending(
                    pendingIndex: pendingIndex,
                    dateComponents: .components(for: challenge.startDate, index: pendingIndex, now: today)
                )
            } else {
                return .pending(
                    pendingIndex: min(index, challenge.duration.unitValueCount),
                    dateComponents: .components(for: challenge.startDate, index: index, now: today)
                )
            }
        } else {
            if challenge.endDate.add(days: 3) <= today.endOfDay {
                return .expired
            }
            guard let pendingIndex = previousPendingIndexOrNullWhenWeekly(for: today) else { return .answered }
            let numberOfWeeksFromStart = challenge.startDate.numberOfWeeks(to: today.startOfDay) + 1
            return .pendingWeekly(pendingIndex: pendingIndex, currentWeekIndex: numberOfWeeksFromStart)
        }
    }

    func previousPendingIndexOrNullWhenDaily(for referenceDate: Date) -> Int? {
        guard
            let ordinal = challenge.ordinal(for: referenceDate), ordinal > 0
        else { return nil }

        let previousRange = max(1, ordinal - 3) ... ordinal

        for day in previousRange.reversed() {
            if answers[day] == nil {
                return day
            }
        }
        return nil
    }

    func previousPendingIndexOrNullWhenWeekly(for referenceDate: Date) -> Int? {
        guard
            let ordinal = challenge.ordinal(for: referenceDate), ordinal > 0
        else { return nil }

        // max one week back
        let previousRange = max(1, ordinal - 1) ... ordinal
        let maxAllowedDate = challenge.startDate.add(weeks: max(1, previousRange.upperBound - 1)).add(days: 2).endOfDay
        guard referenceDate <= maxAllowedDate else { return nil }

        for weekIndex in previousRange.reversed() {
            if answers[weekIndex] == nil {
                return weekIndex
            }
        }
        return nil
    }
}

extension DateComponents {
    static func components(
        for date: Date,
        index: Int,
        now: Date
    ) -> DateComponents {
        Calendar.current.dateComponents([.day], from: now, to: date.add(days: index - 1))
    }
}

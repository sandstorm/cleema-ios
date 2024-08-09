//
//  Created by Kumpels and Friends on 09.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models

public enum AnswerState: Equatable {
    case upcoming(DateComponents)
    case pending(pendingIndex: Int, dateComponents: DateComponents)
    case pendingWeekly(pendingIndex: Int, currentWeekIndex: Int)
    case answered
    case expired
}

extension UserChallenge.State {
    private var pendingIndex: Int? {
        switch answerState {
        case .upcoming, .answered, .expired:
            return nil
        case let .pending(pendingIndex: pendingIndex, _), let .pendingWeekly(pendingIndex: pendingIndex, _):
            return pendingIndex
        }
    }

    mutating func answer(_ answer: JoinedChallenge.Answer, on date: Date) {
        guard let pendingIndex = pendingIndex else { return }

        if !userChallenge.answers.keys.contains(pendingIndex) {
            userChallenge.answers[pendingIndex] = answer
            answerState = .answered
        }

        let todaysIndex = userChallenge.challenge.ordinal(for: date) ?? userChallenge.index(for: date)
        let minIndex = max(1, userChallenge.challenge.interval == .daily ? todaysIndex - 3 : todaysIndex - 1)
        
        if case .collective(_) = userChallenge.kind {
            userChallenge.challenge.collectiveProgress! += 1
        }

        for index in (min(minIndex, pendingIndex) ..< max(minIndex, pendingIndex)).reversed() {
            if userChallenge.answers[index] == nil {
                answerState = userChallenge.challenge.interval == .daily ? .pending(
                    pendingIndex: index,
                    dateComponents: Calendar.current
                        .dateComponents([.day], from: date, to: userChallenge.challenge.startDate.add(days: index - 1))
                ) : .pendingWeekly(pendingIndex: index, currentWeekIndex: todaysIndex)
                break
            }
        }
    }
}

public extension AlertState where Action == UserChallenge.Action {
    static func leave(challengeTitle: String) -> Self {
        .init(title: TextState(L10n.Alert.Leave.Title.label(challengeTitle)), buttons: [
            .cancel(
                TextState(L10n.Alert.Leave.Action.Cancel.label)
            ),
            .destructive(
                TextState(L10n.Alert.Leave.Action.Leave.label),
                action: .send(.leaveConfirmationTapped)
            )
        ])
    }
}

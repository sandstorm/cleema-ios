//
//  Created by Kumpels and Friends on 25.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models
import SwiftUI
import UserClient

public struct UserProgresses: ReducerProtocol {
    public struct State: Equatable {
        public enum Status: Equatable {
            case loading
            case empty
            case content(IdentifiedArrayOf<UserProgress>)
        }

        public var status: Status
        public var maxAllowedAnswers: Int
        public var userProgresses: [UserProgress]

        public init(
            userProgresses: [UserProgress],
            maxAllowedAnswers: Int
        ) {
            self.userProgresses = userProgresses
            self.maxAllowedAnswers = maxAllowedAnswers
            status = .empty
        }
    }

    public enum Action: Equatable {
        case task
        case userResult(User.ID)
    }

    @Dependency(\.userClient) private var userClient

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            state.status = .loading
            return .run { send in
                for await id in userClient.userStream().compactMap({ $0?.user?.id }) {
                    await send(.userResult(id))
                }
            }.animation()
        case let .userResult(userID):
            let userProgresses = state.userProgresses.filter { $0.user.id != userID }
            if userProgresses.isEmpty {
                state.status = .empty
            } else {
                state.status = .content(.init(uniqueElements: userProgresses))
            }
            return .none
        }
    }
}

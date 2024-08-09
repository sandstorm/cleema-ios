//
//  Created by Kumpels and Friends on 09.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models
import UserClient

public struct InviteUsersToChallenge: ReducerProtocol {
    public struct LoadingError: LocalizedError, Equatable {
        public var errorDescription: String?
    }

    public enum State: Equatable {
        case loading
        case content(IdentifiedArrayOf<SocialUser>, selection: Set<SocialUser.ID>)
        case noContent
        case error(LoadingError)
    }

    public enum Action: Equatable {
        case task
        case graphResponse(TaskResult<SocialGraph>)
        case toggleSelectionTapped(SocialUser.ID)
        case saveButtonTapped
        case cancelButtonTapped
    }

    @Dependency(\.userClient) private var userClient

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            state = .loading
            return .run { send in
                for try await graph in userClient.socialGraphStream() {
                    await send(.graphResponse(.success(graph)))
                }
            }
            .animation()
        case let .graphResponse(.success(graph)):
            let followers = graph.followers.map { $0.user }
            if followers.isEmpty {
                state = .noContent
            } else {
                state = .content(.init(uniqueElements: followers), selection: [])
            }
            return .none
        case let .graphResponse(.failure(error)):
            state = .error(LoadingError(errorDescription: error.localizedDescription))
            return .none
        case .saveButtonTapped:
            return .none
        case .cancelButtonTapped:
            return .none
        case let .toggleSelectionTapped(id):
            guard case .content(let followers, var selection) = state else { return .none }
            if selection.contains(id) {
                selection.remove(id)
            } else {
                selection.insert(id)
            }
            state = .content(followers, selection: selection)
            return .none
        }
    }
}

public extension InviteUsersToChallenge.State {
    var selectedFollowers: Set<SocialUser.ID>? {
        guard case let .content(_, selection) = self else {
            return nil
        }
        return selection
    }
}

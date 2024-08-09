//
//  Created by Kumpels and Friends on 06.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models
import UserClient

public extension UserList.SocialUserType {
    var title: String {
        switch self {
        case .followers:
            return L10n.Followers.title
        case .following:
            return L10n.Followings.title
        }
    }
}

public struct UserList: ReducerProtocol {
    public enum SocialUserType {
        case followers
        case following
    }

    public struct LoadingError: LocalizedError, Equatable {
        public var errorDescription: String?
    }

    public struct State: Equatable {
        public enum Status: Equatable {
            case loading
            case content(IdentifiedArrayOf<SocialGraphItem>, selection: Set<SocialGraphItem.ID>)
            case noContent
            case error(LoadingError)
        }

        public var status: Status
        public var socialUserType: SocialUserType
        public var alertState: AlertState<Action>?

        public init(
            socialUserType: SocialUserType,
            alertState: AlertState<Action>? = nil
        ) {
            status = .loading
            self.socialUserType = socialUserType
            self.alertState = alertState
        }
    }

    public enum Action: Equatable {
        case task
        case graphResponse(TaskResult<SocialGraph>)
        case selectedUser(SocialGraphItem)
        case unfollowUserConfirmed(SocialGraphItem)
        case unfollowResponse(TaskResult<Bool>)
        case dismissAlert
    }

    @Dependency(\.userClient) private var userClient

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            state.status = .loading
            return .run { send in
                for try await graph in userClient.socialGraphStream() {
                    await send(.graphResponse(.success(graph)))
                }
            } catch: { error, send in
                await send(.graphResponse(.failure(error)))
            }.animation()
        case let .graphResponse(.success(graph)):
            let users: [SocialGraphItem]
            switch state.socialUserType {
            case .followers:
                users = graph.followers.map { $0 }
            case .following:
                users = graph.following.map { $0 }
            }
            if users.isEmpty {
                state.status = .noContent
            } else {
                state.status = .content(.init(uniqueElements: users), selection: [])
            }
            return .none
        case let .graphResponse(.failure(error)):
            state.status = .error(LoadingError(errorDescription: error.localizedDescription))
            return .none
        case let .selectedUser(user):
            state.alertState = .unfollow(graphItem: user, type: state.socialUserType)
            return .none
        case let .unfollowUserConfirmed(graphItem):
            state.alertState = nil
            return .task {
                .unfollowResponse(
                    await TaskResult {
                        try await userClient.unfollow(graphItem.id)
                        return true
                    }
                )
            }
        case .unfollowResponse(.success):
            return .none
        case let .unfollowResponse(.failure(error)):
            state.alertState = .errorUnfollowing(error: error)
            return .none
        case .dismissAlert:
            state.alertState = nil
            return .none
        }
    }
}

public extension AlertState where Action == UserList.Action {
    static func unfollow(graphItem: SocialGraphItem, type: UserList.SocialUserType) -> Self {
        .init(title: TextState(type.alertTitle(username: graphItem.user.username)), buttons: [
            .cancel(
                TextState(L10n.Alert.Button.cancel)
            ),
            .destructive(
                TextState(type.alertActionTitle),
                action: .send(.unfollowUserConfirmed(graphItem))
            )
        ])
    }

    static func errorUnfollowing(error: Error) -> Self {
        .init(title: TextState(error.localizedDescription), buttons: [
            .cancel(
                TextState("How annoying")
            )
        ])
    }
}

extension UserList.SocialUserType {
    func alertTitle(username: String) -> String {
        switch self {
        case .followers:
            return L10n.Alert.RemoveFollower.withUsername(username)
        case .following:
            return L10n.Alert.RemoveFollowing.withUsername(username)
        }
    }

    var alertActionTitle: String {
        switch self {
        case .followers:
            return L10n.Alert.Button.removeFollower
        case .following:
            return L10n.Alert.Button.removeFollowing
        }
    }
}

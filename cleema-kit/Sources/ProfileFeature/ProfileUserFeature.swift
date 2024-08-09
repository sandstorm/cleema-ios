//
//  Created by Kumpels and Friends on 20.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Alerts
import ComposableArchitecture
import DeepLinking
import SwiftUI
import UserListFeature

public struct ProfileUser: ReducerProtocol {
    public struct State: Equatable {
        public var user: User?
        public var invitationURL: URL?
        public var alertState: AlertState<Action>?
        public var userListState: UserList.State?
        public var accountInfo: String?

        public init(
            user: User? = nil,
            invitationURL: URL? = nil,
            alertState: AlertState<Action>? = nil,
            userListState: UserList.State? = nil,
            accountInfo: String? = nil
        ) {
            self.user = user
            self.invitationURL = invitationURL
            self.alertState = alertState
            self.userListState = userListState
            self.accountInfo = accountInfo
        }
    }

    public enum Action: Equatable {
        case task
        case userResult(User?)
        case inviteButtonTapped
        case convertAccountButtonTapped
        case dismissActivitySheet
        case dismissAlert
        case showFollowersTapped
        case showFollowingsTapped
        case dismissUserList
        case userList(UserList.Action)
        case accountInfoButtonTapped
        case dismissAccountInfo
    }

    @Dependency(\.userClient) private var userClient
    @Dependency(\.deepLinkingClient.urlForRoute) private var urlForRoute

    public init() {}

    public var body: some ReducerProtocolOf<ProfileUser> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for await user in userClient.userStream().compactMap({ $0?.user }) {
                        await send(.userResult(user))
                    }
                }
            case let .userResult(user?):
                state.user = user
                return .none
            case .userResult:
                return .none
            case .inviteButtonTapped where state.user?.kind == .local:
                state.alertState = .invitationDenied
                return .none
            case .inviteButtonTapped:
                guard let user = state.user else { return .none }
                state.invitationURL = urlForRoute(.invitation(user.referralCode))
                return .none
            case .dismissActivitySheet:
                state.invitationURL = nil
                return .none
            case .dismissAlert:
                state.alertState = nil
                return .none
            case .showFollowersTapped:
                state.userListState = .init(socialUserType: .followers)
                return .none
            case .showFollowingsTapped:
                state.userListState = .init(socialUserType: .following)
                return .none
            case .dismissUserList:
                state.userListState = nil
                return .none
            case .userList:
                return .none
            case .convertAccountButtonTapped:
                return .none
            case .accountInfoButtonTapped:
                guard let user = state.user else { return .none }
                state.accountInfo = user.kind == .local ? L10n.Account.Info.localUser : L10n.Account.Info.remoteUser
                return .none
            case .dismissAccountInfo:
                state.accountInfo = nil
                return .none
            }
        }
        .ifLet(\.userListState, action: /Action.userList, then: UserList.init)
    }
}

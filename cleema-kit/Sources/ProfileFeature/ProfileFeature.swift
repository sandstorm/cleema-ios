//
//  Created by Kumpels and Friends on 25.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Foundation
import Logging
import Models
import ProfileEditFeature
import QuizClient
import QuizFeature
import RegisterUserFeature
import TrophiesFeature
import UserClient
import UserFavoritesFeature

public struct Profile: ReducerProtocol {
    public struct State: Equatable {
        public var profileDataState: ProfileData.State
        public var trophiesFeatureState: Trophies.State
        public var userFavoritesState: UserFavorites.State
        public var alertState: AlertState<Action>?
        public var errorState: ValidationError

        public init(
            profileDataState: ProfileData.State = .show(),
            trophiesFeatureState: Trophies.State = .init(),
            userFavoritesState: UserFavorites.State = .init(),
            alertState: AlertState<Action>? = nil,
            isEditingProfile: Bool = false,
            errorState: ValidationError = []
        ) {
            self.profileDataState = profileDataState
            self.trophiesFeatureState = trophiesFeatureState
            self.userFavoritesState = userFavoritesState
            self.alertState = alertState
            self.errorState = errorState
        }

        public var isEditingProfile: Bool {
            switch profileDataState {
            case .show: return false
            default: return true
            }
        }
    }

    // MARK: - Actions

    public enum Action: Equatable {
        case profileData(ProfileData.Action)
        case trophies(Trophies.Action)
        case userFavorites(UserFavorites.Action)
        case removeProfileTapped
        case dismissAlert
        case confirmAccountDeletion
        case logoutTapped
        case deleteAccountResponse(TaskResult<Bool>)
        case editProfileButtonTapped
    }

    @Dependency(\.userClient) var userClient
    @Dependency(\.log) var log

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.trophiesFeatureState, action: /Profile.Action.trophies) {
            Trophies()
        }

        Scope(state: \.profileDataState, action: /Profile.Action.profileData) {
            ProfileData()
        }

        Scope(state: \.userFavoritesState, action: /Profile.Action.userFavorites) {
            UserFavorites()
        }

        Reduce { state, action in
            switch action {
            case .profileData(.user(.convertAccountButtonTapped)):
                guard case let .show(userState) = state.profileDataState,
                      let user = userState.user
                else {
                    return .none
                }
                state.profileDataState = .convertAccount(.init(registerUser: .init(
                    name: user.name,
                    password: "",
                    confirmation: "",
                    email: "",
                    acceptsSurveys: user.acceptsSurveys,
                    selectRegionState: .init(regions: [], selectedRegion: user.region)
                ), localUserId: user.id))
                return .none
            case .trophies, .userFavorites:
                return .none
            case .removeProfileTapped:
                state.alertState = .remove
                return .none
            case .dismissAlert:
                state.alertState = nil
                return .none
            case .confirmAccountDeletion:
                guard case .show = state.profileDataState
                else {
                    return .none
                }
                return .task {
                    await .deleteAccountResponse(
                        TaskResult {
                            try await userClient.delete()
                        }
                    )
                }
            case .logoutTapped:
                guard case let .show(userState) = state.profileDataState, let user = userState.user else {
                    return .none
                }
                return .fireAndForget { [userID = user.id] in
                    try await userClient.logout(userID)
                }
            case let .deleteAccountResponse(.failure(error)):
                state.alertState = .deletionError
                return .fireAndForget {
                    log.error("Account deletion failed", userInfo: error.logInfo)
                }
            case .deleteAccountResponse:
                return .none
            case .editProfileButtonTapped:
                guard case let .show(userState) = state.profileDataState,
                      let user = userState.user
                else {
                    return .none
                }
                state.profileDataState = .edit(.init(user: user))
                return .none
            case .profileData(.editProfile(.cancelButtonTapped)):
                guard case .edit = state.profileDataState else {
                    return .none
                }
                state.profileDataState = .show()
                return .none
            case .profileData(.editProfile(.saveResult(.success))):
                state.profileDataState = .show()
                return .none
            case .profileData(.convertAccount(.cancelButtonTapped)):
                guard case .convertAccount = state.profileDataState else { return .none }
                state.profileDataState = .show(.init())
                return .none
            case .profileData(.convertAccount(.convertAccountResult(.success))):
                state.profileDataState = .show()
                return .none
            case .profileData(.convertAccount(.convertAccountResult(.failure))):
                return .none
            case .profileData(.editProfile):
                return .none
            case .profileData(.convertAccount):
                return .none
            case .profileData:
                return .none
            }
        }
    }
}

public extension AlertState where Action == Profile.Action {
    static let remove: Self = .init(
        title: TextState(L10n.Account.Alert.Remove.title),
        buttons: [
            .cancel(
                TextState(L10n.Account.Alert.Remove.Button.Cancel.label)
            ),
            .destructive(
                TextState(
                    L10n.Account.Alert.Remove.Button.Remove.label
                ),
                action: .send(.confirmAccountDeletion)
            )
        ]
    )

    static let deletionError: Self = .init(
        title: TextState("Account deletion failed"),
        buttons: [
            .cancel(
                TextState("Dismiss")
            )
        ]
    )
}

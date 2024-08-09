//
//  Created by Kumpels and Friends on 03.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import ProfileEditFeature
import RegisterUserFeature

public struct ProfileData: ReducerProtocol {
    public enum State: Equatable {
        case show(ProfileUser.State = .init())
        case edit(ProfileEdit.State)
        case convertAccount(ConvertAccount.State)
    }

    public enum Action: Equatable {
        case user(ProfileUser.Action)
        case editProfile(ProfileEdit.Action)
        case convertAccount(ConvertAccount.Action)
        case cancelButtonTapped
        case submitConvertAccountTapped
    }

    public var body: some ReducerProtocolOf<ProfileData> {
        Reduce { state, action in
            .none
        }
        .ifCaseLet(/State.show, action: /Action.user, then: ProfileUser.init)
        .ifCaseLet(/State.edit, action: /Action.editProfile, then: ProfileEdit.init)
        .ifCaseLet(/State.convertAccount, action: /Action.convertAccount, then: ConvertAccount.init)
    }
}

public extension ProfileData.State {
    var isEditingProfile: Bool {
        switch self {
        case .show: return false
        default: return true
        }
    }

    var user: User? {
        switch self {
        case let .show(state):
            return state.user
        case let .edit(state):
            return state.originalUser
        case .convertAccount:
            return nil
        }
    }
}

import SwiftUI
struct ProfileDataView: View {
    let store: StoreOf<ProfileData>

    var body: some View {
        WithViewStore(store) { viewStore in
            SwitchStore(store) {initialState in
                switch initialState {
                    case .edit:
                        CaseLet(/ProfileData.State.edit, action: ProfileData.Action.editProfile) { store in
                            ProfileEditView(store: store)
                                .transition(.scale)
                                .animation(.default, value: viewStore.isEditingProfile)
                        }
                    case .convertAccount:
                        CaseLet(/ProfileData.State.convertAccount, action: ProfileData.Action.convertAccount) { store in
                            ConvertAccountView(store: store)
                                .transition(.scale)
                                .animation(.default, value: viewStore.isEditingProfile)
                        }
                    case .show:
                        CaseLet(/ProfileData.State.show, action: ProfileData.Action.user) { store in
                            ProfileUserView(store: store)
                                .transition(.opacity)
                                .animation(.default, value: viewStore.isEditingProfile)
                        }
                }
            }
        }
    }
}

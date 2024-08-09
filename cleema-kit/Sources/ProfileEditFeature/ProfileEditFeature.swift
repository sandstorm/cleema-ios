//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Logging
import Models
import SelectAvatarFeature
import SelectRegionFeature
import SwiftUI
import UserClient

public struct ProfileEdit: ReducerProtocol {
    public enum Status: Equatable {
        case editing(ValidationError = [])
        case saving
        case error(String)
    }

    public struct EditingUser: Equatable {
        public var name: String
        public var password: String = ""
        public var passwordConfirmation: String = ""
        public var oldPassword: String = ""
        public var region: Region
        public var email: String = ""
        public var acceptsSurveys: Bool
        public var avatar: IdentifiedImage?

        public var showsPasswordConfirmationField: Bool {
            !password.isEmpty
        }
    }

    public struct State: Equatable {
        public var originalUser: User
        @BindingState
        public var editedUser: EditingUser
        public var alertState: AlertState<Action>?
        public var selectRegionState: SelectRegion.State
        public var selectAvatarState: SelectAvatar.State?

        public var status: Status = .editing()
        public var showsPasswordHint = false

        var isSaving: Bool {
            status == .saving
        }

        public init(
            user: User,
            alertState: AlertState<Action>? = nil
        ) {
            originalUser = user
            self.alertState = alertState
            selectRegionState = .init(selectedRegion: user.region)

            if case let .remote(_, email) = user.kind {
                editedUser = .init(
                    name: user.name,
                    region: user.region,
                    email: email,
                    acceptsSurveys: user.acceptsSurveys,
                    avatar: user.avatar
                )
            } else {
                editedUser = .init(
                    name: user.name,
                    region: user.region,
                    acceptsSurveys: user.acceptsSurveys,
                    avatar: user.avatar
                )
            }
        }
    }

    public enum Action: Equatable, BindableAction {
        case cancelButtonTapped
        case saveButtonTapped
        case selectAvatarTapped
        case dismissSelectAvatarSheet
        case binding(BindingAction<State>)
        case selectRegion(SelectRegion.Action)
        case selectAvatar(SelectAvatar.Action)
        case saveResult(TaskResult<User>)
        case showPasswordHint
        case dismissPasswordHint
        case clearErrorTapped
    }

    @Dependency(\.userClient.updateUser) private var updateUser
    @Dependency(\.log) private var log

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        BindingReducer()

        Scope(state: \.selectRegionState, action: /Action.selectRegion, child: SelectRegion.init)

        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .none
            case .saveButtonTapped:
                let editUser = state.editedUser.diff(from: state.originalUser)
                if !editUser.isEmpty {
                    let error = validate(state, editUser: editUser)
                    state.status = .editing(error)

                    guard error.isEmpty else { return .none }

                    state.status = .saving

                    return .task {
                        .saveResult(
                            await TaskResult {
                                try await updateUser(editUser)
                            }
                        )
                    }
                    .animation(.default)
                } else {
                    return .task { [user = state.originalUser] in
                        .saveResult(.success(user))
                    }
                    .animation(.default)
                }
            case .selectAvatarTapped:
                state.selectAvatarState = .init(selectedAvatar: state.editedUser.avatar)
                return .none
            case .dismissSelectAvatarSheet, .selectAvatar(.cancelButtonTapped):
                state.selectAvatarState = nil
                return .none
            case .binding:
                return .none
            case .selectRegion(.binding(\.$selectedRegion)):
                guard let region = state.selectRegionState.selectedRegion else { return .none }
                state.editedUser.region = region
                return .none
            case .selectRegion:
                return .none
            case .selectAvatar(.saveButtonTapped):
                guard let avatar = state.selectAvatarState?.selectedAvatar else { return .none }
                state.editedUser.avatar = avatar
                state.selectAvatarState = nil
                return .none
            case .selectAvatar:
                return .none
            case .saveResult(.success):
                return .none
            case let .saveResult(.failure(error)):
                state.status = .error(error.localizedDescription)
                return .none
            case .showPasswordHint:
                state.showsPasswordHint = true
                return .none
            case .dismissPasswordHint:
                state.showsPasswordHint = false
                return .none
            case .clearErrorTapped:
                state.status = .editing()
                return .none
            }
        }
        .ifLet(\.selectAvatarState, action: /Action.selectAvatar, then: SelectAvatar.init)
    }

    func validate(_ state: State, editUser: EditUser) -> ValidationError {
        var validationError: ValidationError = []

        if editUser.username != nil {
            let editedName = state.editedUser.name.trimmingCharacters(in: .whitespaces)
            if editedName.isEmpty {
                validationError.insert(.name)
            }
        }

        if editUser.password != nil {
            if state.editedUser.password.count < 10 {
                validationError.insert(.passwordLength)
            }

            if state.editedUser.password != state.editedUser.passwordConfirmation {
                validationError.insert(.notMatching)
            }

            if state.originalUser.password != state.editedUser.oldPassword {
                validationError.insert(.oldPasswordNotMatching)
            }
        }

        if editUser.email != nil {
            @Dependency(\.emailValidator) var emailValidator
            if emailValidator.validate(state.editedUser.email) == nil {
                validationError.insert(.email)
            }
        }

        return validationError
    }
}

extension ProfileEdit.Status {
    var hint: String? {
        switch self {
        case let .editing(error):
            return error.hint
        case let .error(reason):
            return reason
        default:
            return nil
        }
    }
}

extension User {
    var password: String {
        if case let .remote(pwd, _) = kind {
            return pwd
        } else {
            return ""
        }
    }

    var email: String {
        if case let .remote(_, email) = kind {
            return email
        } else {
            return ""
        }
    }
}

extension ProfileEdit.EditingUser {
    func diff(from user: User) -> EditUser {
        if case .remote = user.kind, let avatar {
            return EditUser(
                username: name != user.name ? name : nil,
                password: (!password.isEmpty && password != user.password) ? password : nil,
                email: email != user.email ? email : nil,
                acceptsSurveys: acceptsSurveys != user.acceptsSurveys ? acceptsSurveys : nil,
                region: region != user.region ? region : nil,
                avatar: avatar.id != user.avatar?.id ? avatar : nil
            )
        } else {
            return EditUser(
                username: name != user.name ? name : nil,
                password: nil,
                email: nil,
                acceptsSurveys: acceptsSurveys != user.acceptsSurveys ? acceptsSurveys : nil,
                region: region != user.region ? region : nil,
                avatar: avatar
            )
        }
    }

    func isDifferent(from user: User) -> Bool {
        !diff(from: user).isEmpty
    }
}

extension EditUser {
    var isEmpty: Bool {
        username == nil &&
            password == nil &&
            email == nil &&
            acceptsSurveys == nil &&
            region == nil &&
            avatar == nil
    }
}

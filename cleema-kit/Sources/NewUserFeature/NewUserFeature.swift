//
//  Created by Kumpels and Friends on 02.03.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import CreateUserFeature
import Foundation
import RegisterUserFeature

public struct NewUser: ReducerProtocol {
    public struct State: Equatable {
        public enum Status: Equatable {
            case editing(ValidationError = [])
            case saving
            case done(User)
            case error(String)
            case pendingConfirmation(Credentials)
        }

        public enum Selection: Hashable, CaseIterable, Identifiable {
            case local
            case server

            public var id: Self {
                self
            }
        }

        public var createUserState: CreateUser.State
        public var registerUserState: RegisterUser.State
        public var status: Status = .editing()
        @BindingState public var selection: Selection

        public init(
            createUserState: CreateUser.State = .init(),
            registerUserState: RegisterUser.State = .init(),
            status: Status = .editing(),
            selection: Selection = .local
        ) {
            self.createUserState = createUserState
            self.registerUserState = registerUserState
            self.status = status
            self.selection = selection
        }
    }

    public enum Action: Equatable, BindableAction {
        case createUser(CreateUser.Action)
        case registerUser(RegisterUser.Action)
        case binding(BindingAction<State>)
        case saveTapped
        case saveResult(TaskResult<User>)
        case loginButtonTapped
        case clearErrorTapped
        case registerResult(TaskResult<Credentials>)
        case resetTapped
    }

    @Dependency(\.uuid) private var uuid
    @Dependency(\.date.now) private var now
    @Dependency(\.userClient) private var userClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Scope(
            state: \.createUserState,
            action: /Action.createUser,
            child: CreateUser.init
        )

        Scope(
            state: \.registerUserState,
            action: /Action.registerUser,
            child: RegisterUser.init
        )

        Reduce { state, action in
            switch action {
            case .saveTapped where state.selection == .server:
                let validationError = validate(state)
                guard validationError.isEmpty else {
                    state.status = .editing(validationError)
                    return .none
                }

                guard let region = state.registerUserState.selectRegionState.selectedRegion
                else { return .none }
                state.status = .saving
                return .task { [
                    name = state.registerUserState.name,
                    password = state.registerUserState.password,
                    email = state.registerUserState.email,
                    acceptsSurveys = state.registerUserState.acceptsSurveys,
                    referralCode = state.registerUserState.referralCode
                ] in
                    await .registerResult(
                        TaskResult {
                            try await userClient.register(
                                RegisterUserModel(
                                    username: name,
                                    password: password,
                                    email: email,
                                    acceptsSurveys: acceptsSurveys,
                                    region: region,
                                    referralCode: referralCode
                                )
                            )
                            return Credentials(username: name, password: password, email: email)
                        }
                    )
                }
            case .saveTapped:
                let validationError = validate(state)
                guard validationError.isEmpty else {
                    state.status = .editing(validationError)
                    return .none
                }

                guard let region = state.createUserState.selectRegionState.selectedRegion else { return .none }
                state.status = .saving
                let user = User(
                    id: .init(rawValue: uuid()),
                    name: state.createUserState.name.trimmingCharacters(in: .whitespaces),
                    region: region,
                    joinDate: now,
                    acceptsSurveys: state.createUserState.acceptsSurveys,
                    referralCode: "",
                    avatar: nil
                )
                return .task {
                    await .saveResult(
                        TaskResult {
                            try await userClient.saveUser(.user(user))
                            return user
                        }
                    )
                }
            case let .saveResult(.success(user)):
                state.status = .done(user)
                return .none
            case let .saveResult(.failure(error)):
                state.status = .error(error.localizedDescription)
                return .none
            case .createUser, .registerUser, .binding:
                state.status = .editing()
                return .none
            case .loginButtonTapped:
                return .none
            case .clearErrorTapped:
                state.status = .editing()
                return .none
            case let .registerResult(.success(credentials)):
                state.status = .pendingConfirmation(credentials)
                return .fireAndForget {
                    try await userClient.saveUser(.pending(credentials))
                }
            case let .registerResult(.failure(error)):
                state.status = .error(error.localizedDescription)
                return .none
            case .resetTapped:
                state = .init()
                return .fireAndForget {
                    _ = try await userClient.delete()
                }
            }
        }
    }

    func validate(_ state: State) -> ValidationError {
        var validationError: ValidationError = []

        switch state.selection {
        case .local:
            let editedName = state.createUserState.name.trimmingCharacters(in: .whitespaces)
            if editedName.isEmpty {
                validationError.insert(.name)
            }
            if state.createUserState.selectRegionState.selectedRegion == nil {
                validationError.insert(.region)
            }
        case .server:
            @Dependency(\.emailValidator) var emailValidator
            let editedName = state.registerUserState.name.trimmingCharacters(in: .whitespaces)
            if state.registerUserState.password.count < 10 {
                validationError.insert(.passwordLength)
            }
            if state.registerUserState.password != state.registerUserState.confirmation {
                validationError.insert(.notMatching)
            }
            if emailValidator.validate(state.registerUserState.email) == nil {
                validationError.insert(.email)
            }
            if editedName.isEmpty {
                validationError.insert(.name)
            }
            if state.registerUserState.selectRegionState.selectedRegion == nil {
                validationError.insert(.region)
            }
        }
        return validationError
    }
}

extension NewUser.State.Selection {
    var title: String {
        switch self {
        case .local:
            return L10n.AccountType.local
        case .server:
            return L10n.AccountType.server
        }
    }
}

extension NewUser.State {
    var hint: String? {
        switch status {
        case let .editing(validationError):
            return validationError.hint
        case .saving:
            return nil
        case .done:
            return nil
        case let .error(message):
            return message
        case .pendingConfirmation:
            return nil
        }
    }
}

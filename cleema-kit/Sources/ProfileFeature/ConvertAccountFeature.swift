//
//  Created by Kumpels and Friends on 25.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Foundation
import RegisterUserFeature
import SwiftUI
import UserClient

public struct ConvertAccount: ReducerProtocol {
    public struct State: Equatable {
        public var registerUser: RegisterUser.State
        public var localUserId: User.ID
        public var errorState: ValidationError
        public var remoteErrorMessage: String?

        public init(
            registerUser: RegisterUser.State,
            localUserId: User.ID,
            errorState: ValidationError = [],
            remoteErrorMessage: String? = nil
        ) {
            self.registerUser = registerUser
            self.localUserId = localUserId
            self.errorState = errorState
            self.remoteErrorMessage = remoteErrorMessage
        }
    }

    public enum Action: Equatable {
        case registerUser(RegisterUser.Action)
        case convertAccountResult(TaskResult<Credentials>)
        case submitConvertAccountTapped
        case convertAccountButtonTapped
        case cancelButtonTapped
        case clearErrorTapped
    }

    @Dependency(\.userClient) var userClient

    public init() {}

    public var body: some ReducerProtocolOf<ConvertAccount> {
        Scope(state: \.registerUser, action: /Action.registerUser) {
            RegisterUser()
        }

        Reduce { state, action in
            switch action {
            case .submitConvertAccountTapped:
                state.remoteErrorMessage = nil
                let validationError = validate(state)

                guard validationError.isEmpty else {
                    state.errorState = validationError
                    return .none
                }

                state.errorState = []

                guard
                    let region = state.registerUser.selectRegionState.selectedRegion
                else { return .none }

                let registerModel = RegisterUserModel(
                    username: state.registerUser.name,
                    password: state.registerUser.password,
                    email: state.registerUser.email,
                    acceptsSurveys: state.registerUser.acceptsSurveys,
                    region: region,
                    clientID: state.localUserId.rawValue
                )

                return .task {
                    await .convertAccountResult(
                        TaskResult {
                            try await userClient.register(registerModel)
                            return Credentials(
                                username: registerModel.username,
                                password: registerModel.password,
                                email: registerModel.email
                            )
                        }
                    )
                }
            case let .convertAccountResult(.success(credentials)):
                return .fireAndForget {
                    try await userClient.saveUser(.pending(credentials))
                }
            case let .convertAccountResult(.failure(error)):
                state.remoteErrorMessage = error.localizedDescription
                return .none
            case .registerUser, .convertAccountButtonTapped, .cancelButtonTapped:
                return .none
            case .clearErrorTapped:
                state.remoteErrorMessage = nil
                state.errorState = []
                return .none
            }
        }
    }

    private func validate(_ state: State) -> ValidationError {
        var validationError: ValidationError = []

        let userState = state.registerUser
        @Dependency(\.emailValidator) var emailValidator
        let editedName = userState.name.trimmingCharacters(in: .whitespaces)
        if userState.password.count < 10 {
            validationError.insert(.passwordLength)
        }
        if userState.password != userState.confirmation {
            validationError.insert(.notMatching)
        }
        if emailValidator.validate(userState.email) == nil {
            validationError.insert(.email)
        }
        if editedName.isEmpty {
            validationError.insert(.name)
        }
        if userState.selectRegionState.selectedRegion == nil {
            validationError.insert(.region)
        }

        return validationError
    }
}

public struct ConvertAccountView: View {
    let store: StoreOf<ConvertAccount>

    public init(store: StoreOf<ConvertAccount>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                if let hint = viewStore.errorState.hint {
                    ErrorHintView(message: hint) {
                        viewStore.send(.clearErrorTapped, animation: .default)
                    }
                }

                if let hint = viewStore.remoteErrorMessage {
                    ErrorHintView(message: hint) {
                        viewStore.send(.clearErrorTapped, animation: .default)
                    }
                }

                RegisterUserView(store: store.scope(state: \.registerUser, action: ConvertAccount.Action.registerUser))
                    .transition(.scale)
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                viewStore.send(.cancelButtonTapped, animation: .default)
                            } label: {
                                Text(L10n.Action.CancelConvertAccount.label)
                            }
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button {
                                viewStore.send(.submitConvertAccountTapped, animation: .default)
                            } label: {
                                Text(L10n.Action.ConvertAccount.label)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
            }
        }
    }
}

//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import AppFeature
import AuthenticateUserFeature
import ComposableArchitecture
import Models
import NewUserFeature
import SwiftUI

public struct Login: ReducerProtocol {
    public enum State: Equatable {
        case fetching
        case loggedIn(AppFeature.App.State)
        case newUser(NewUser.State)
        case authenticate(AuthenticateUser.State)
    }

    public enum Action: Equatable {
        case loggedIn(AppFeature.App.Action)
        case newUser(NewUser.Action)
        case authenticateUser(AuthenticateUser.Action)
        case task
        case fetching
        case userResult(UserValue?)
        case confirmAccount(code: String)
        case confirmAccountResponse(TaskResult<Models.Credentials>)
    }

    @Dependency(\.userClient) private var userClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for await user in userClient.userStream() {
                        await send(.userResult(user))
                    }
                }
            case .userResult(nil):
                state = .newUser(.init())
                return .none
            case let .userResult(.user(user)):
                if !state.isLoggedIn {
                    state = user.kind == .local ? .loggedIn(.init(user: user)) : .authenticate(.init(user: user))
                }
                return .none
            case let .userResult(.pending(credentials)):
                state = .newUser(.init(status: .pendingConfirmation(credentials)))
                return .none
            case let .newUser(.saveResult(.success(user))),
                 let .authenticateUser(.authenticationResponse(.success(user))):
                state = .loggedIn(.init(user: user))
                return .none
            case .loggedIn(.profile(.logoutTapped)):
                state = .newUser(.init())
                return .none
            case .loggedIn(.profile(.deleteAccountResponse(.success))):
                state = .newUser(.init())
                return .none
            case .newUser, .loggedIn, .authenticateUser:
                return .none
            case let .confirmAccount(code: code):
                guard case let .newUser(newUserState) = state else { return .none }
                guard case let .pendingConfirmation(credentials) = newUserState.status else { return .none }

                return .run { send in
                    await send(.confirmAccountResponse(
                        await TaskResult {
                            try await userClient.confirmAccount(code)
                            return credentials
                        }
                    ))
                }
            case let .confirmAccountResponse(.success(credentials)):
                state =
                    .authenticate(.init(credentials: .init(name: credentials.username, password: credentials.password)))
                return .none
            case .confirmAccountResponse(.failure):
                return .run { send in
                    await send( .newUser(.loginButtonTapped) )
                }
            case .fetching:
                return .none
            }
        }
        .ifCaseLet(/State.newUser, action: /Action.newUser, then: NewUser.init)
        .ifCaseLet(/State.loggedIn, action: /Action.loggedIn, then: App.init)
        .ifCaseLet(/State.authenticate, action: /Action.authenticateUser, then: AuthenticateUser.init)
    }
}

extension Login.State {
    var isLoggedIn: Bool {
        switch self {
        case .loggedIn:
            return true
        case .fetching, .newUser, .authenticate:
            return false
        }
    }
}

public struct LoginView: View {
    let store: StoreOf<Login>

    public init(store: StoreOf<Login>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            SwitchStore(store) {initialState in
                switch initialState {
                    case .loggedIn:
                        CaseLet(/Login.State.loggedIn, action: Login.Action.loggedIn) { loggedInStore in
                            AppView(store: loggedInStore)
                                .transition(.opacity)
                        }
                    case .newUser:
                        CaseLet(/Login.State.newUser, action: Login.Action.newUser) { newUserStore in
                            NavigationView {
                                NewUserView(store: newUserStore)
                            }
                            .foregroundColor(.defaultText)
                            .transition(.opacity)
                        }
                    case .authenticate:
                        CaseLet(/Login.State.authenticate, action: Login.Action.authenticateUser) { _ in
                            // We show a fake NewUser view as the login gets presented from the MainView
                            NavigationView {
                                NewUserView(store: .init(initialState: .init(), reducer: NewUser()))
                            }
                            .foregroundColor(.defaultText)
                            .transition(.opacity)
                        }
                    case .fetching:
                        CaseLet(/Login.State.fetching, action: Login.Action.newUser) { _ in
                            NavigationView {
                                ZStack {
                                    ProgressView()
                                        .tint(.defaultText)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.accent)
                            }
                        }
                }
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
//        LoginView(
//            store: .init(
//                initialState: .authenticate(
//                    .init(
//                        user: .init(
//                            name: "user",
//                            region: .dresden,
//                            joinDate: .now,
//                            referralCode: "clara-coda"
//                        )
//                    )
//                ),
//                reducer: Login()
//            )
//        )

        LoginView(
            store: .init(
                initialState: .newUser(
                    .init(
                        status: .pendingConfirmation(Credentials(
                            username: "hansbernd",
                            password: "geheim",
                            email: "mail@cleema.app"
                        ))
                    )
                ),
                reducer: Login().dependency(\.userClient, .pending)
            )
        )
    }
}

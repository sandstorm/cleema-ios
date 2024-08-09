//
//  Created by Kumpels and Friends on 02.03.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import AuthenticateUserFeature
import ComposableArchitecture
import DeepLinking
import Foundation
import LoginFeature
import SwiftUI
import SwiftUIBackports

public struct Main: ReducerProtocol {
    public struct State: Equatable {
        public var login: Login.State
        public var deepLinkingState: DeepLinking.State

        public init(
            login: Login.State = .fetching,
            loginSheetState: AuthenticateUser.State? = nil,
            deepLinkingState: DeepLinking.State = .init()
        ) {
            self.login = login
            self.deepLinkingState = deepLinkingState
        }
    }

    public enum Action: Equatable {
        case login(Login.Action)
        case authenticate(AuthenticateUser.Action)
        case deepLinking(DeepLinking.Action)
        case dismissSheet
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.login, action: /Action.login) {
            Login()
        }

        Scope(state: \.deepLinkingState, action: /Action.deepLinking, child: DeepLinking.init)

        Reduce { state, action in
            switch action {
            case .login(.newUser(.loginButtonTapped)):
                state.loginSheetState = .init(credentials: .empty)
                return .none
            case .dismissSheet:
                state.loginSheetState = nil
                return .none
            case let .authenticate(.authenticationResponse(.success(user))):
                state.loginSheetState = nil
                state.login = .loggedIn(.init(user: user))
                return .none
            case let .deepLinking(.matchedRoute(.success(route))):
                switch state.login {
                case .loggedIn:
                    return .task {
                        .login(.loggedIn(.handleAppRoute(route)))
                    }
                case let .newUser(newUserState):
                    switch route {
                    case let .invitation(code):
                        var updatedNewUserState = newUserState
                        updatedNewUserState.registerUserState.referralCode = code
                        state.login = .newUser(updatedNewUserState)
                    default:
                        break
                    }
                    return .none
                case .fetching, .authenticate:
                    switch route {
                    case let .emailConfirmationRequest(code):
                        return .task { .login(.confirmAccount(code: code)) }
                    default:
                        return .none
                    }
                }
            case .login(.loggedIn(.handleAppRouteResponse)):
                state.deepLinkingState.matchedRoute = nil
                return .none
            case .deepLinking, .login, .authenticate:
                return .none
            }
        }
        .ifLet(\.loginSheetState, action: /Action.authenticate, then: AuthenticateUser.init)
    }
}

public extension Main.State {
    var loginSheetState: AuthenticateUser.State? {
        get {
            guard case let .authenticate(state) = login else {
                return nil
            }
            return state
        }
        set {
            guard let newValue else {
                if case .authenticate = login {
                    login = .newUser(.init())
                }
                return
            }
            login = .authenticate(newValue)
        }
    }
}

public struct MainView: View {
    let store: StoreOf<Main>

    public init(store: StoreOf<Main>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            LoginView(store: store.scope(state: \.login, action: Main.Action.login))
                .sheet(
                    isPresented: viewStore.binding(
                        get: { $0.loginSheetState != nil },
                        send: Main.Action.dismissSheet
                    )
                ) {
                    IfLetStore(
                        store
                            .scope(
                                state: \.loginSheetState,
                                action: Main.Action.authenticate
                            ),
                        then: {
                            AuthenticateUserView(store: $0)
                                .backport.presentationDragIndicator(.visible)
                        },
                        else: {
                            Color.accent.ignoresSafeArea()
                                .backport.presentationDragIndicator(.visible)
                        }
                    )
                    .backport.presentationDetents([.large])
                }
                .onOpenURL {
                    viewStore.send(.deepLinking(.handleDeepLink($0)))
                }
        }
    }
}

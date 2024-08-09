//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Logging
import Models
import Styling
import UserClient

extension User {
    var password: String? {
        guard case let .remote(pw, _) = kind else { return nil }
        return pw
    }
}

public struct AuthenticateUser: ReducerProtocol {
    public struct State: Equatable {
        public enum Status: Equatable {
            case loading
            case success
            case error(String)
        }

        public var user: User?
        public var credentials: Credentials.State?
        public var status: Status = .loading

        public init(user: User? = nil, credentials: Credentials.State? = nil, status: State.Status = .loading) {
            self.user = user
            self.credentials = credentials
            self.status = status
        }
    }

    public enum Action: Equatable {
        case authenticate
        case authenticationResponse(TaskResult<User>)
        case credentials(Credentials.Action)
        case clearErrorTapped
    }

    @Dependency(\.userClient) var userClient
    @Dependency(\.log) var log

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .authenticate where state.credentials == nil:
                guard let user = state.user else { return .none }
                guard case let .remote(password, _) = user.kind else { return .none }
                state.status = .loading
                return .task {
                    if await userClient.isAuthenticated(user.id) {
                        return .authenticationResponse(.success(user))
                    }
                    return .authenticationResponse(await TaskResult {
                        try await userClient.authenticate(user.name, password)
                    })
                }
            case .authenticate:
                guard
                    let credentials = state.credentials,
                    credentials.isComplete
                else {
                    state.status = .success
                    return .none
                }

                state.status = .loading
                return .task {
                    return .authenticationResponse(await TaskResult {
                        try await userClient.authenticate(credentials.name, credentials.password)
                    })
                }
                .animation(.default)
            case let .authenticationResponse(.success(user)):
                state.status = .success
                state.user = user
                state.credentials = nil
                return .none
            case let .authenticationResponse(.failure(error)):
                state.status = .error(error.localizedDescription)
                state.credentials = .init(name: state.user?.name ?? "", password: "")
                return .fireAndForget { [user = state.user] in
                    let userInfo = {
                        if let user {
                            return ["user": user.name, "userId": user.id, "error": error]
                        } else {
                            return ["user": "nil", "error": error]
                        }
                    }()
                    log.error("Could not log in user", userInfo: userInfo)
                }
            case .credentials:
                return .none
            case .clearErrorTapped:
                state.status = .error("")
                return .none
            }
        }.ifLet(\.credentials, action: /Action.credentials, then: Credentials.init)
    }
}

extension AuthenticateUser.State.Status {
    var hint: String? {
        switch self {
        case .loading, .success:
            return nil
        case let .error(message):
            return message.isEmpty ? nil : message
        }
    }
}

import Components
import SwiftUI

public struct AuthenticateUserView: View {
    let store: StoreOf<AuthenticateUser>

    public init(store: StoreOf<AuthenticateUser>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                IfLetStore(
                    store
                        .scope(state: \.credentials, action: AuthenticateUser.Action.credentials)
                ) { credentialsStore in
                    VStack(alignment: .center, spacing: 24) {
                        Styling.cleemaLogo
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 63)
                            .padding(.top, 24)

                        Text(L10n.Login.hint)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let hint = viewStore.status.hint {
                            ErrorHintView(message: hint) {
                                viewStore.send(.clearErrorTapped, animation: .default)
                            }
                        }

                        CredentialsView(store: credentialsStore)

                        HStack {
                            Button {
                                viewStore.send(.authenticate)
                            } label: {
                                HStack(spacing: 10) {
                                    Text(L10n.Button.Login.title)
                                    if viewStore.status == .loading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                }
                            }
                            .disabled(viewStore.credentials?.isComplete == false || viewStore.status == .loading)
                            .buttonStyle(.action(maxWidth: .infinity))
                        }
                        .padding(.vertical)

                        Spacer()
                    }
                    .padding()
                } else: {
                    ZStack {
                        ProgressView(label: {
                            Text(L10n.Login.Progress.title(viewStore.user?.name ?? ""))
                        })
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Asset.onboardingWave.image
                    .resizable()
                    .scaledToFit()
                    .allowsHitTesting(false)
                    .overlay(
                        Color.dimmed
                            .frame(height: 768)
                            .frame(maxWidth: .infinity)
                            .offset(y: 768),
                        alignment: .bottom
                    )
            }
            .foregroundColor(.defaultText)
            .font(.montserrat(style: .body, size: 16))
            .ignoresSafeArea(edges: .bottom)
            .background(Color.accent, ignoresSafeAreaEdges: .all)
            .onAppear {
                viewStore.send(.authenticate, animation: .default)
            }
        }
    }
}

struct AuthenticateUserView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Something went wrong")
        }
        .sheet(isPresented: .constant(true), content: {
            AuthenticateUserView(
                store: .init(
                    initialState: .init(credentials: .empty),
                    reducer: AuthenticateUser()
                )
            )
            .navigationTitle("Login")
        })
        .cleemaStyle()
        .previewDisplayName("Login Form")

        VStack {
            Text("Something went wrong")
        }
        .sheet(isPresented: .constant(true), content: {
            AuthenticateUserView(
                store: .init(
                    initialState: .init(user: User(
                        name: "User",
                        region: .leipzig,
                        joinDate: .now,
                        kind: .remote(password: "1234", email: "hi@there.com"),
                        referralCode: "01234-4321",
                        avatar: .fake(image: .fake(width: 312, height: 312))
                    )),
                    reducer: AuthenticateUser()
                )
            )
            .navigationTitle("Login")
        })
        .cleemaStyle()
        .previewDisplayName("Logging in")
    }
}

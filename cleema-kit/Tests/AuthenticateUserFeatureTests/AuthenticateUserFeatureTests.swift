//
//  Created by Kumpels and Friends on 23.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import AuthenticateUserFeature
import UserClient
import XCTest

@MainActor
final class AuthenticateUserFeatureTests: XCTestCase {
    struct TestError: Error, Equatable {}

    func testAuthenticatedUserInTheClientWillNotLogin() async throws {
        let user = User(
            name: "Remote user",
            region: .pirna,
            joinDate: .now,
            kind: .remote(password: "password", email: "mail@domain.de"),
            referralCode: "foo-bar"
        )
        let store = TestStore(initialState: .init(user: user, status: .success), reducer: AuthenticateUser())
        store.dependencies.userClient.isAuthenticated = { _ in true }

        await store.send(.authenticate) {
            $0.status = .loading
        }

        await store.receive(.authenticationResponse(.success(user))) {
            $0.user = user
            $0.credentials = nil
            $0.status = .success
        }
    }

    func testSuccessfulAutoLogin() async throws {
        let user = User(
            name: "Remote user",
            region: .leipzig,
            joinDate: .now,
            kind: .remote(password: "password", email: "mail@domain.de"),
            referralCode: "remote"
        )
        let store = TestStore(initialState: .init(user: user, status: .success), reducer: AuthenticateUser())
        store.dependencies.userClient.isAuthenticated = { _ in false }
        store.dependencies.userClient.authenticate = { name, pw in
            guard name == user.name, pw == "password" else { throw TestError() }
            return user
        }

        await store.send(.authenticate) {
            $0.status = .loading
        }

        await store.receive(.authenticationResponse(.success(user))) {
            $0.user = user
            $0.status = .success
            $0.credentials = nil
        }
    }

    func testFailedAutoLogin() async throws {
        let user = User(
            name: "Remote user",
            region: .dresden,
            joinDate: .now,
            kind: .remote(password: "password", email: "mail@domain.de"),
            referralCode: "remote"
        )
        let store = TestStore(initialState: .init(user: user, status: .success), reducer: AuthenticateUser()) {
            $0.userClient.isAuthenticated = { _ in false }
            $0.userClient.authenticate = { _, _ in throw TestError() }
            $0.log.log = { _, _, _, _, _, _ in }
        }

        await store.send(.authenticate) {
            $0.status = .loading
        }

        await store.receive(.authenticationResponse(.failure(TestError()))) {
            $0.credentials = .init(name: user.name, password: "")
            $0.status = .error(TestError().localizedDescription)
        }
    }

    func testEditingCredentials() async throws {
        let store = TestStore(initialState: .init(user: User(
            name: "Remote user",
            region: .pirna,
            joinDate: .now,
            kind: .remote(password: "password", email: "mail@domain.de"),
            referralCode: "remote"
        ), credentials: .init(name: "", password: ""), status: .success), reducer: AuthenticateUser())

        await store.send(.credentials(.binding(.set(\.$name, "name")))) {
            $0.credentials?.name = "name"
        }

        await store.send(.credentials(.binding(.set(\.$password, "1111")))) {
            $0.credentials?.password = "1111"
        }

        let user = User(name: "autenticated", region: .leipzig, joinDate: .now, referralCode: "authenticated")
        store.dependencies.userClient.authenticate = { name, pw in
            guard name == "name", pw == "1111" else { throw TestError() }
            return user
        }

        await store.send(.authenticate) {
            $0.status = .loading
        }

        await store.receive(.authenticationResponse(.success(user))) {
            $0.user = user
            $0.credentials = nil
            $0.status = .success
        }
    }
}

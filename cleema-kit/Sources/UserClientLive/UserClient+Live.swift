//
//  Created by Kumpels and Friends on 27.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import APIClient
import AsyncAlgorithms
import Boundaries
import Combine
import Foundation
import KeychainAccess
import Models
import UserClient

public extension UserClient {
    struct Error: LocalizedError, Equatable {
        var reason: String

        public var errorDescription: String? { reason }
    }

    static func live(apiClient: APIClient) -> Self {
        let userStore = UserStore()

        let userSubject = CurrentValueSubject<UserValue?, Never>(nil)
        let socialGraphSubject = CurrentValueSubject<SocialGraph, Never>(.init(followers: [], following: []))

        let storeUser = loadUser()
        apiClient.clientID = storeUser?.user?.id.rawValue
        userSubject.send(storeUser)

        return .init(
            saveUser: { userValue in
                if let user = userValue.user {
                    // we set the user id as anonymous client id
                    apiClient.clientID = user.id.rawValue
                }

                await userStore.update(userValue)
                userSubject.send(userValue)
            },
            register: { registerUser in
                try await apiClient.register(
                    user: registerUser.username,
                    password: registerUser.password,
                    email: registerUser.email,
                    acceptsSurveys: registerUser.acceptsSurveys,
                    regionID: registerUser.region.id,
                    avatarID: registerUser.avatar?.id,
                    clientID: registerUser.clientID,
                    referralCode: registerUser.referralCode
                )
            },
            logout: { _ in
                apiClient.deauthorize()

                await userStore.update(nil)
                userSubject.send(nil)
            },
            delete: {
                if let user = await userStore.value?.user,
                   case .remote = user.kind
                {
                    try await apiClient.deleteUser(userID: user.id)
                }

                await userStore.update(nil)
                userSubject.send(nil)

                return true
            },
            isAuthenticated: { userID in
                guard await userStore.value != nil else { return false }
                return await apiClient.isAuthenticated(userID: userID)
            },
            authenticate: { name, password in
                let user = try await apiClient.login(user: name, password: password)
                await userStore.update(.user(user))
                userSubject.send(.user(user))
                return user
            },
            followInvitation: { referralCode in
                let result = try await apiClient.followInvitation(referralCode: referralCode)
                let savedPW = await userStore.value?.user?.password ?? ""
                let user = try await apiClient.me(pwd: savedPW)
                await userStore.update(.user(user))
                userSubject.send(.user(user))
                return result
            },
            userStream: {
                AsyncStream { cont in
                    let task = Task {
                        await cont.yield(userStore.value)
                        for await userValue in userSubject.values {
                            guard !Task.isCancelled else {
                                cont.finish()
                                return
                            }
                            cont.yield(userValue)
                        }
                    }
                    cont.onTermination = { _ in
                        task.cancel()
                    }
                }
            },
            updateUser: { editUser in
                guard let savedUser = await userStore.value?.user
                else { throw Error(reason: "Update failed. User nil!") }

                let user: User
                if case .remote = savedUser.kind {
                    _ = try await apiClient.updateUser(userID: savedUser.id, user: editUser)
                    let savedPW = savedUser.password ?? ""
                    user = try await apiClient.me(pwd: savedPW)
                } else {
                    var updatedUser = savedUser
                    updatedUser.name = editUser.username ?? savedUser.name
                    updatedUser.region = editUser.region ?? savedUser.region
                    updatedUser.acceptsSurveys = editUser.acceptsSurveys ?? savedUser.acceptsSurveys
                    updatedUser.avatar = editUser.avatar
                    user = updatedUser
                }
                await userStore.update(.user(user))
                userSubject.send(.user(user))
                return user
            },
            socialGraphStream: {
                AsyncThrowingStream { cont in
                    let task = Task {
                        let result = try await apiClient.follows()
                        socialGraphSubject.send(result)

                        for await graph in socialGraphSubject.values {
                            guard !Task.isCancelled else {
                                cont.finish()
                                return
                            }
                            cont.yield(graph)
                        }
                    }
                    cont.onTermination = { _ in
                        task.cancel()
                    }
                }
            },
            unfollow: { graphItemID in
                let graph = try await apiClient.unfollow(graphItemID: graphItemID)
                let savedPW = await userStore.value?.user?.password ?? ""
                let user = try await apiClient.me(pwd: savedPW)
                await userStore.update(.user(user))
                userSubject.send(.user(user))
                socialGraphSubject.send(graph)
            },
            confirmAccount: { code in
                try await apiClient.confirmAccount(code: code)
            },
            reloadUser: {
                let savedPW = await userStore.value?.user?.password ?? ""
                let user = try await apiClient.me(pwd: savedPW)
                userSubject.send(.user(user))
            }
        )
    }

    private static func loadUser() -> UserValue? {
        let keychain = Keychain()
        return keychain.user
    }

    static func removeUser() {
        Keychain().user = nil
    }
}

private actor UserStore {
    let keychain = Keychain()
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    func update(_ userValue: UserValue?) {
        keychain.user = userValue
    }

    var value: UserValue? {
        keychain.user
    }
}

extension User {
    var password: String? {
        switch kind {
        case .local:
            return nil
        case .remote(password: let password, email: _):
            return password
        }
    }
}

private extension Keychain {
    static let decoder: JSONDecoder = .init()
    static let encoder: JSONEncoder = .init()

    var user: UserValue? {
        get {
            guard
                let data = self[data: KeychainKeys.savedUser.rawValue],
                let user = try? Self.decoder.decode(UserValue.self, from: data)
            else { return nil }
            return user
        }
        set {
            let encoded: Data? = newValue.flatMap { try? Self.encoder.encode($0) }
            self[data: KeychainKeys.savedUser.rawValue] = encoded
        }
    }
}

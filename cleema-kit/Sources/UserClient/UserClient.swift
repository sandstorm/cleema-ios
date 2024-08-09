//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Boundaries
import Dependencies
import Foundation
import Models

public enum UserValue: Equatable, Codable {
    case user(User)
    case pending(Credentials)
}

public extension UserValue {
    var user: User? {
        switch self {
        case let .user(user):
            return user
        case .pending:
            return nil
        }
    }
}

public struct UserClient {
    public var saveUser: @Sendable (UserValue) async throws -> Void
    public var register: @Sendable (RegisterUserModel) async throws -> Void
    public var logout: @Sendable (User.ID) async throws -> Void
    public var delete: @Sendable () async throws -> Bool
    public var isAuthenticated: @Sendable (User.ID) async -> Bool
    public var authenticate: @Sendable (_ name: String, _ password: String) async throws -> User
    public var followInvitation: @Sendable (String) async throws -> SocialGraphItem
    public var userStream: @Sendable () -> AsyncStream<UserValue?>
    public var updateUser: @Sendable (EditUser) async throws -> User
    public var socialGraphStream: @Sendable () -> AsyncThrowingStream<SocialGraph, Error>
    public var unfollow: (SocialGraphItem.ID) async throws -> Void
    public var confirmAccount: (String) async throws -> Void
    public var reloadUser: @Sendable () async throws -> Void

    public init(
        saveUser: @Sendable @escaping (UserValue) async throws -> Void,
        register: @Sendable @escaping (RegisterUserModel) async throws -> Void,
        logout: @Sendable @escaping (User.ID) async throws -> Void,
        delete: @Sendable @escaping () async throws -> Bool,
        isAuthenticated: @Sendable @escaping (User.ID) async -> Bool,
        authenticate: @Sendable @escaping (_ name: String, _ password: String) async throws -> User,
        followInvitation: @Sendable @escaping (String) async throws -> SocialGraphItem,
        userStream: @Sendable @escaping () -> AsyncStream<UserValue?>,
        updateUser: @Sendable @escaping (EditUser) async throws -> User,
        socialGraphStream: @Sendable @escaping () -> AsyncThrowingStream<SocialGraph, Error>,
        unfollow: @Sendable @escaping (SocialGraphItem.ID) async throws -> Void,
        confirmAccount: @Sendable @escaping (String) async throws -> Void,
        reloadUser: @Sendable @escaping () async throws -> Void
    ) {
        self.saveUser = saveUser
        self.register = register
        self.logout = logout
        self.delete = delete
        self.isAuthenticated = isAuthenticated
        self.authenticate = authenticate
        self.followInvitation = followInvitation
        self.userStream = userStream
        self.updateUser = updateUser
        self.socialGraphStream = socialGraphStream
        self.unfollow = unfollow
        self.confirmAccount = confirmAccount
        self.reloadUser = reloadUser
    }
}

public extension UserClient {
    static let preview: Self = .init(
        saveUser: { _ in
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)
            throw NSError(domain: "Preview error", code: 42)
        },
        register: { user in
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
        },
        logout: { _ in },
        delete: { true },
        isAuthenticated: { _ in
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
            return Bool.random()
        },
        authenticate: { name, pw in
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
            struct PreviewError: Error {
                var localizedDescription: String = "Login failed"
            }
            if Bool.random() { throw PreviewError() }
            return User(
                name: name,
                region: .leipzig,
                joinDate: .now,
                kind: .remote(password: pw, email: "\(name)@cleema.app"),
                acceptsSurveys: Bool.random(),
                referralCode: .word(),
                avatar: .fake(image: .fake(width: 120, height: 120))
            )
        },
        followInvitation: { _ in
            .fake()
        },
        userStream: { AsyncStream {
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
            return .user(User(
                name: "Clara Cleema",
                region: .leipzig,
                joinDate: .now,
                kind: .remote(password: "pw", email: "clara@cleema.app"),
                referralCode: "1234"
            ))
        }},
        updateUser: { _ in
            User(
                name: .word(),
                region: .leipzig,
                joinDate: .now,
                kind: .remote(password: .word(), email: "\(String.word())@cleema.app"),
                acceptsSurveys: Bool.random(),
                referralCode: .word(),
                avatar: .fake(image: .fake(width: 120, height: 120))
            )
        },
        socialGraphStream: {
            AsyncThrowingStream { continuation in
                continuation.yield(
                    SocialGraph(
                        followers: [
                            .init(
                                id: .init(.init()),
                                user: .init(id: .init(.init()), username: "mmlr")
                            ),
                            .init(
                                id: .init(.init()),
                                user: .init(id: .init(.init()), username: "ricobeck")
                            ),
                            .init(
                                id: .init(.init()),
                                user: .init(id: .init(.init()), username: "rbw")
                            )
                        ],
                        following: []
                    )
                )
            }
        },
        unfollow: { _ in },
        confirmAccount: { _ in },
        reloadUser: {}
    )

    static let pending: UserClient = {
        var client = UserClient.preview
        client.userStream = {
            .init {
                UserValue.pending(Credentials(username: "hansbernd", password: "geheim", email: "mail@cleema.app"))
            }
        }
        return client
    }()
}

import XCTestDynamicOverlay

public extension UserClient {
    static let unimplemented: Self = UserClient(
        saveUser: XCTestDynamicOverlay.unimplemented("\(Self.self).saveUser"),
        register: XCTestDynamicOverlay.unimplemented("\(Self.self).register"),
        logout: XCTestDynamicOverlay.unimplemented("\(Self.self).logout"),
        delete: XCTestDynamicOverlay.unimplemented("\(Self.self).delete"),
        isAuthenticated: XCTestDynamicOverlay.unimplemented("\(Self.self).isAuthenticated", placeholder: false),
        authenticate: XCTestDynamicOverlay.unimplemented("\(Self.self).authenticate", placeholder: .empty),
        followInvitation: XCTestDynamicOverlay.unimplemented("\(Self.self).followInvitation", placeholder: .fake()),
        userStream: XCTestDynamicOverlay.unimplemented(
            "\(Self.self).userStream",
            placeholder: AsyncStream(unfolding: { .user(.empty) })
        ),
        updateUser: XCTestDynamicOverlay.unimplemented("\(Self.self).updateUser"),
        socialGraphStream: {
            AsyncThrowingStream { continuation in
                continuation.yield(
                    SocialGraph(
                        followers: [
                            .init(
                                id: .init(.init()),
                                user: .init(id: .init(.init()), username: "mmlr")
                            ),
                            .init(
                                id: .init(.init()),
                                user: .init(id: .init(.init()), username: "ricobeck")
                            ),
                            .init(
                                id: .init(.init()),
                                user: .init(id: .init(.init()), username: "rbw")
                            )
                        ],
                        following: []
                    )
                )
            }
        },
        unfollow: XCTestDynamicOverlay.unimplemented("\(Self.self).unfollow"),
        confirmAccount: XCTestDynamicOverlay.unimplemented("\(Self.self).confirmAccount"),
        reloadUser: XCTestDynamicOverlay.unimplemented("\(Self.self).reloadUser")
    )
}

public enum UserClientKey: TestDependencyKey {
    public static let testValue = UserClient.unimplemented
    public static let previewValue = UserClient.preview
}

public extension DependencyValues {
    var userClient: UserClient {
        get { self[UserClientKey.self] }
        set { self[UserClientKey.self] = newValue }
    }
}

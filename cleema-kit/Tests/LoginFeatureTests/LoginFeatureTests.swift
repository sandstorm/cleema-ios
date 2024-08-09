//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import AppFeature
import LoginFeature
import ProfileFeature
import XCTest

@MainActor
final class LoginFeatureTests: XCTestCase {
    func testCreatingALocalUser() async throws {
        let store = TestStore(
            initialState: .newUser(.init()),
            reducer: Login()
        )

        let user = User(name: "user", region: .pirna, joinDate: .now, referralCode: "code")
        await store.send(.newUser(.saveResult(.success(user)))) {
            $0 = .loggedIn(.init(user: user))
        }
    }

    func testCreatingAServerUser() async throws {
        let store = TestStore(
            initialState: .newUser(.init()),
            reducer: Login()
        )

        let user = User(name: "user", region: .leipzig, joinDate: .now, referralCode: "code")
        await store.send(.newUser(.saveResult(.success(user)))) {
            $0 = .loggedIn(.init(user: user))
        }
    }

    func testRemovingUser() async throws {
        let user = User(name: "user", region: .pirna, joinDate: .now, referralCode: "code")
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let deleteInvoked = LockIsolated(false)

        let store = TestStore(
            initialState: .loggedIn(.init(user: user, showsProfile: true)),
            reducer: Login()
        ) {
            $0.userClient.delete = {
                deleteInvoked.setValue(true)
                return true
            }

            $0.userClient.userStream = { userStream }
        }
        store.exhaustivity = .off

        let task = await store.send(.loggedIn(.profile(.profileData(.user(.task)))))
        userContinuation.yield(.user(user))

        await store.receive(.loggedIn(.profile(.profileData(.user(.userResult(user))))))

        await store.send(.loggedIn(.profile(.confirmAccountDeletion)))

        await store.receive(.loggedIn(.profile(.deleteAccountResponse(.success(true))))) {
            $0 = .newUser(.init())
        }

        XCTAssertTrue(deleteInvoked.value)

        await task.cancel()
    }

    func testRemovingUserFails() async throws {
        struct TestError: Error, Equatable {}

        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let user = User(name: "user", region: .pirna, joinDate: .now, referralCode: "code")
        let deleteInvoked = LockIsolated(false)
        let store = TestStore(
            initialState: .loggedIn(.init(user: user, showsProfile: true)),
            reducer: Login()
        ) {
            $0.userClient.delete = {
                throw TestError()
            }
            $0.log.log = { _, _, _, _, _, _ in }

            $0.userClient.userStream = { userStream }
        }

        store.exhaustivity = .off

        let task = await store.send(.loggedIn(.profile(.profileData(.user(.task)))))
        userContinuation.yield(.user(user))

        await store.receive(.loggedIn(.profile(.profileData(.user(.userResult(user))))))
        await store.send(.loggedIn(.profile(.confirmAccountDeletion)))
        await store.receive(.loggedIn(.profile(.deleteAccountResponse(.failure(TestError())))))

        XCTAssertFalse(deleteInvoked.value)

        await task.cancel()
    }

    func testLoginWithAuthenticatedServerUser() async throws {
        let user = User(
            name: "authenticated",
            region: .leipzig,
            joinDate: .now,
            kind: .remote(password: "123", email: "m@domain.de"), referralCode: "code"
        )
        let store = TestStore(
            initialState: .authenticate(.init(user: user)),
            reducer: Login()
        )

        await store.send(.authenticateUser(.authenticationResponse(.success(user)))) {
            $0 = .loggedIn(.init(user: user))
        }
    }

    func testUserLogout() async throws {
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let user = User(name: "user", region: .pirna, joinDate: .now, referralCode: "code")
        let loggedOutUser = ActorIsolated<User.ID?>(nil)

        let store = TestStore(
            initialState: .loggedIn(.init(user: user, showsProfile: true)),
            reducer: Login()
        ) {
            $0.userClient.logout = { user in
                await loggedOutUser.setValue(user)
            }
            $0.userClient.userStream = { userStream }
        }

        store.exhaustivity = .off

        let task = await store.send(.loggedIn(.profile(.profileData(.user(.task)))))
        userContinuation.yield(.user(user))

        await store.receive(.loggedIn(.profile(.profileData(.user(.userResult(user))))))

        await store.send(.loggedIn(.profile(.logoutTapped))) {
            $0 = .newUser(.init())
        }

        await loggedOutUser.withValue { XCTAssertEqual(user.id, $0) }

        await task.cancel()
    }

    func testFetchingUserFromUserClient() async throws {
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let store = TestStore(
            initialState: .fetching,
            reducer: Login()
        ) {
            $0.userClient.userStream = { userStream }
        }

        let task = await store.send(.task)

        userContinuation.yield(nil)

        await store.receive(.userResult(nil)) {
            $0 = .newUser(.init())
        }

        var user: User = .init(name: "user", region: .pirna, joinDate: .now, referralCode: "code")
        userContinuation.yield(.user(user))

        var expectedState: App.State = .init(user: user)
        await store.receive(.userResult(.user(user))) {
            $0 = .loggedIn(expectedState)
        }

        expectedState.destination = .sheet(.profile(.init()))
        await store.send(.loggedIn(.dashboard(.profileButtonTapped))) {
            $0 = .loggedIn(expectedState)
        }

        user.followerCount = 42
        // modified app state while running the app
        let challenges: [Challenge] = [.fake(kind: .partner(.fake())), .fake(kind: .partner(.fake()))]
        expectedState.challengesState.partnerChallengesState?.challenges = .init(uniqueElements: challenges)
        await store.send(.loggedIn(.challenges(.partnerChallenges(.loadResponse(.success(challenges)))))) {
            $0 = .loggedIn(expectedState)
        }

        await task.cancel()
    }

    func testRemoteUserMustBeAuthenticatedInitially() async throws {
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let store = TestStore(
            initialState: .fetching,
            reducer: Login()
        ) {
            $0.userClient.userStream = { userStream }
        }

        let task = await store.send(.task)

        let user: User = .init(
            name: "user",
            region: .pirna,
            joinDate: .now,
            kind: .remote(password: "unsicher", email: "email"),
            referralCode: "code"
        )
        userContinuation.yield(.user(user))

        await store.receive(.userResult(.user(user))) {
            $0 = .authenticate(.init(user: user))
        }

        await task.cancel()
    }

    func testFetchingPendingUserFromClient() async throws {
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let store = TestStore(
            initialState: .fetching,
            reducer: Login()
        ) {
            $0.userClient.userStream = { userStream }
        }

        let task = await store.send(.task)

        let credentials = Credentials(username: "user", password: "pw", email: "mail")
        userContinuation.yield(.pending(credentials))

        await store.receive(.userResult(.pending(credentials))) {
            $0 = .newUser(.init(status: .pendingConfirmation(credentials)))
        }

        await task.cancel()
    }

    func testNilUserValueFromClientWhenInPendingConfirmation() async throws {
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let store = TestStore(
            initialState: .newUser(.init(status: .pendingConfirmation(Credentials(
                username: "user",
                password: "pw",
                email: "mail"
            )))),
            reducer: Login()
        ) {
            $0.userClient.userStream = { userStream }
        }

        let task = await store.send(.task)

        userContinuation.yield(nil)

        await store.receive(.userResult(nil)) {
            $0 = .newUser(.init())
        }

        await task.cancel()
    }
}

extension App.State {
    init(user: User, showsProfile: Bool = false) {
        self.init(
            surveysState: .init(userAcceptedSurveys: user.acceptsSurveys),
            dashboardGridState: .init(),
            newsState: .init(searchState: .init(region: user.region.id)),
            projectsState: .init(selectRegionState: .init(
                selectedRegion: user.region
            )),
            challengesState: .init(selectRegionState: .init(
                selectedRegion: user.region
            ), userRegion: user.region),
            marketplaceState: .init(selectRegionState: .init(
                selectedRegion: user.region
            )),
            selectedSection: .dashboard,
            destination: showsProfile ? .sheet(.profile(.init())) : nil
        )
    }
}

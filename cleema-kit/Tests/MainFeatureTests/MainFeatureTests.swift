//
//  Created by Kumpels and Friends on 25.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import MainFeature
import XCTest

@MainActor
final class MainFeatureTests: XCTestCase {
    func testSuccessfulDeepLinksWillBeForwardedToTheAppFeatureWhenLoggedIn() async throws {
        let user = User.emptyRemote
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()

        let store = TestStore(
            initialState: .init(login: .loggedIn(.init(user: user))),
            reducer: Main()
        ) {
            $0.userClient.followInvitation = { _ in .fake() }
            $0.userClient.userStream = { userStream }
        }
        store.exhaustivity = .off

        let task = await store.send(.login(.loggedIn(.task)))
        userContinuation.yield(.user(user))
        await store.receive(.login(.loggedIn(.userResult(user))))

        await store.send(.deepLinking(.matchedRoute(.success(.invitation("1234"))))) {
            $0.deepLinkingState.matchedRoute = .invitation("1234")
        }

        await store.receive(.login(.loggedIn(.handleAppRoute(.invitation("1234")))))

        await store.receive(.login(.loggedIn(.handleAppRouteResponse))) {
            $0.deepLinkingState.matchedRoute = nil
        }

        await task.cancel()
    }

    func testReferralCodeIsHandedToNewUserState() async throws {
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let store = TestStore(
            initialState: .init(),
            reducer: Main()
        ) {
            $0.deepLinkingClient.routeForURL = { _ in
                .invitation("abcd")
            }
            $0.userClient.userStream = {
                userStream
            }
        }

        let task = await store.send(.login(.task))
        userContinuation.yield(nil)

        await store.receive(.login(.userResult(nil))) {
            $0.login = .newUser(.init())
        }

        await store.send(.deepLinking(.handleDeepLink(URL(string: "https://localhost/invites/abcd")!)))

        await store.receive(.deepLinking(.matchedRoute(.success(.invitation("abcd"))))) {
            $0.deepLinkingState.matchedRoute = .invitation("abcd")
            $0.login = .newUser(.init(registerUserState: .init(referralCode: "abcd")))
        }

        await task.cancel()
    }
}

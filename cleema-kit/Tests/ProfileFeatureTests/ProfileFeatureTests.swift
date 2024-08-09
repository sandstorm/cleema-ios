//
//  Created by Kumpels and Friends on 25.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ProfileFeature
import UserClient
import XCTest
import XCTestDynamicOverlay

@MainActor
final class ProfileFeatureTests: XCTestCase {
    func testFlow() async throws {
        let user = User(name: "Clara Cleema", region: .pirna, joinDate: .now, referralCode: "clara-coda")
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()

        let store = TestStore(
            initialState: .init(),
            reducer: Profile()
        ) {
            $0.userClient.userStream = { userStream }
        }

        store.exhaustivity = .off

        let task = await store.send(.profileData(.user(.task)))
        userContinuation.yield(.user(user))

        await store.receive(.profileData(.user(.userResult(user))))

        await store.send(.removeProfileTapped) {
            $0.alertState = .remove
        }

        await store.send(.dismissAlert) {
            $0.alertState = nil
        }

        await store.send(.removeProfileTapped) {
            $0.alertState = .remove
        }

        let deleteInvoked = LockIsolated(false)
        store.dependencies.userClient.delete = {
            deleteInvoked.setValue(true)
            return true
        }
        await store.send(.confirmAccountDeletion)

        await store.receive(.deleteAccountResponse(.success(true)))

        XCTAssertTrue(deleteInvoked.value)

        await task.cancel()
    }

    func testLogout() async throws {
        let user = User(name: "Clara Cleema", region: .pirna, joinDate: .now, referralCode: "clara-coda")
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let loggedOutUserID = ActorIsolated<User.ID?>(nil)

        let store = TestStore(
            initialState: .init(),
            reducer: Profile()
        ) {
            $0.userClient.logout = { await loggedOutUserID.setValue($0) }
            $0.userClient.userStream = { userStream }
        }

        store.exhaustivity = .off

        let task = await store.send(.profileData(.user(.task)))
        userContinuation.yield(.user(user))

        await store.receive(.profileData(.user(.userResult(user))))

        await store.send(.logoutTapped)

        await loggedOutUserID.withValue { loggedOutUserID in
            XCTAssertEqual(user.id, loggedOutUserID)
        }

        await task.cancel()
    }
}

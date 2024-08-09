//
//  Created by Kumpels and Friends on 22.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Models
import UserListFeature
import XCTest

@MainActor
final class UserListFeatureTests: XCTestCase {
    func testFlow() async throws {
        let socialGraphStream = AsyncThrowingStream<SocialGraph, Error>.streamWithContinuation()

        let store = TestStore(
            initialState: .init(socialUserType: .followers),
            reducer: UserList()
        ) {
            $0.userClient.socialGraphStream = { socialGraphStream.stream }
        }

        let task = await store.send(.task)

        let emptyGraph = SocialGraph(followers: [], following: [])
        socialGraphStream.continuation.yield(emptyGraph)

        await store.receive(.graphResponse(.success(emptyGraph))) {
            $0.status = .noContent
        }

        let expectedGraph = SocialGraph(
            followers: [
                .fake(),
                .fake(),
                .fake(),
                .fake()
            ],
            following: []
        )
        socialGraphStream.continuation.yield(expectedGraph)

        let expectedGraphItems = IdentifiedArray(uniqueElements: expectedGraph.followers)
        await store.receive(.graphResponse(.success(expectedGraph))) {
            $0.status = .content(expectedGraphItems, selection: [])
        }

        await task.cancel()
    }
}

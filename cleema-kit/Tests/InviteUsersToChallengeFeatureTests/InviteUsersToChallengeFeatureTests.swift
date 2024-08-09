//
//  Created by Kumpels and Friends on 22.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import InviteUsersToChallengeFeature
import Models
import XCTest

@MainActor
final class InviteUsersToChallengeFeatureTests: XCTestCase {
    func testFlow() async throws {
        let socialGraphStream = AsyncThrowingStream<SocialGraph, Error>.streamWithContinuation()

        let store = TestStore(
            initialState: .loading,
            reducer: InviteUsersToChallenge()
        ) {
            $0.userClient.socialGraphStream = { socialGraphStream.stream }
        }

        let task = await store.send(.task)

        let emptyGraph = SocialGraph(followers: [], following: [])
        socialGraphStream.continuation.yield(emptyGraph)

        await store.receive(.graphResponse(.success(emptyGraph))) {
            $0 = .noContent
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

        let expectedFollowers =
            IdentifiedArray(uniqueElements: expectedGraph.followers.map { $0.user })
        await store.receive(.graphResponse(.success(expectedGraph))) {
            $0 = .content(expectedFollowers, selection: [])
        }

        await store.send(.toggleSelectionTapped(expectedGraph.followers[0].user.id)) {
            $0 = .content(expectedFollowers, selection: [expectedGraph.followers[0].user.id])
        }

        await store.send(.toggleSelectionTapped(expectedGraph.followers[2].user.id)) {
            $0 = .content(
                expectedFollowers,
                selection: [expectedGraph.followers[0].user.id, expectedGraph.followers[2].user.id]
            )
        }

        await store.send(.toggleSelectionTapped(expectedGraph.followers[0].user.id)) {
            $0 = .content(expectedFollowers, selection: [expectedGraph.followers[2].user.id])
        }

        await store.send(.toggleSelectionTapped(expectedGraph.followers[2].user.id)) {
            $0 = .content(expectedFollowers, selection: [])
        }

        await task.cancel()
    }
}

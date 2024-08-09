//
//  Created by Kumpels and Friends on 29.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import PartnerChallengesFeature
import XCTest

@MainActor
final class PartnerChallengesFeatureTests: XCTestCase {
    func testLoadingChallengesWillFilterUserChallenges() async throws {
        struct LoadError: Error, Equatable {}
        let challenges = [Challenge.fake(kind: .partner(.fake())), .fake(kind: .partner(.fake())), .fake(kind: .user)]
        let expectedChallenges = Array(challenges.dropLast(1))
        let challengesStream = AsyncThrowingStream<[Challenge], Error>.streamWithContinuation()

        let store = TestStore(initialState: .init(region: .pirna, challenges: []), reducer: PartnerChallengeList()) {
            $0.challengesClient.partnerChallenges = { _ in challengesStream.stream }
        }

        let task = await store.send(.task) {
            $0.isLoading = true
        }

        challengesStream.continuation.yield(challenges)

        await store.receive(.loadResponse(.success(challenges))) {
            $0.challenges = .init(uniqueElements: expectedChallenges)
            $0.isLoading = false
        }

        challengesStream.continuation.finish(throwing: LoadError())

        let newStream = AsyncThrowingStream<[Challenge], Error>.streamWithContinuation()
        store.dependencies.challengesClient.partnerChallenges = { _ in newStream.stream }

        await store.receive(.loadResponse(.failure(LoadError()))) {
            $0.challenges = []
            $0.isLoading = false
        }

        await task.finish()
    }

    func testChallengeDetails() async throws {
        let challenges = [Challenge.fake(isJoined: false), .fake()]
        let joinedChallengeID = ActorIsolated<Challenge.ID?>(nil)
        let leftChallengeID = ActorIsolated<Challenge.ID?>(nil)

        let store = TestStore(
            initialState: .init(region: .pirna, challenges: .init(uniqueElements: challenges)),
            reducer: PartnerChallengeList()
        ) {
            $0.challengesClient.joinPartnerChallenge = { id in
                await joinedChallengeID.setValue(id)
                var retVal = challenges[0]
                retVal.isJoined = true
                return retVal
            }
            $0.challengesClient.leaveChallenge = { id in
                await leftChallengeID.setValue(id)
                var retVal = challenges[0]
                retVal.isJoined = false
                return retVal
            }
        }

        var expectedChallenge = challenges[0]
        await store.send(.setNavigation(expectedChallenge.id)) {
            $0.selection = .init(.init(challenge: expectedChallenge), id: expectedChallenge.id)
        }

        await store.send(.detail(.joinLeaveButtonTapped)) {
            $0.selection?.isLoading = true
        }

        expectedChallenge.isJoined = true
        await store.receive(.detail(.joinResult(.success(expectedChallenge)))) {
            $0.selection?.isLoading = false
            $0.selection?.challenge = expectedChallenge
        }

        await joinedChallengeID.withValue { [expectedChallengeID = expectedChallenge.id] in
            XCTAssertEqual(expectedChallengeID, $0)
        }

        await store.send(.detail(.joinLeaveButtonTapped)) {
            $0.selection?.isLoading = true
        }

        expectedChallenge.isJoined = false
        await store.receive(.detail(.leaveResult(.success(expectedChallenge)))) {
            $0.selection?.isLoading = false
            $0.selection?.challenge = expectedChallenge
        }

        await leftChallengeID.withValue { [expectedChallengeID = expectedChallenge.id] in
            XCTAssertEqual(expectedChallengeID, $0)
        }

        await store.send(.setNavigation(nil)) {
            $0.selection = nil
        }
    }
}

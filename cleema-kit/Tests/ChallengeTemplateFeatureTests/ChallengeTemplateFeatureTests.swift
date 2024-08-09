//
//  Created by Kumpels and Friends on 06.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ChallengeTemplateFeature
import EditChallengeFeature
import Models
import Overture
import UserClient
import XCTest

@MainActor
final class ChallengeTemplateFeatureTests: XCTestCase {
    struct SaveValue: Equatable {
        var challenge: Challenge
        var participants: Set<SocialUser.ID>
    }

    func testFlow() async throws {
        let userRegion: Region = [.leipzig, .dresden, .pirna].randomElement()!
        let socialGraphStream = AsyncThrowingStream<SocialGraph, Error>.streamWithContinuation()
        let fixedID: Challenge.ID = .init(rawValue: .init())
        let challenges: [Challenge] = [.init(type: .measurement(12, .kilograms)), .init()]
        let savedValue = ActorIsolated<SaveValue?>(nil)
        let (stream, cont) = AsyncStream<UserValue?>.streamWithContinuation()
        let store = TestStore(
            initialState: .init(challenges: [], userRegion: userRegion),
            reducer: ChallengeTemplates()
        ) {
            $0.challengesClient.fetchTemplates = { challenges }
            $0.challengesClient.save = { challenge, participants in
                await savedValue.setValue(SaveValue(challenge: challenge, participants: participants))
                return challenge
            }
            $0.challengeID = .constant(fixedID)
            $0.userClient.socialGraphStream = { socialGraphStream.stream }
            $0.userClient.userStream = { stream }
        }

        await store.send(.load)

        await store.receive(.challengeResponse(.success(challenges))) {
            $0.challenges = .init(uniqueElements: challenges)
        }

        let tappedChallenge = challenges[0]
        await store.send(.challengeTapped(id: tappedChallenge.id)) {
            $0.editState = .init(
                .init(
                    challenge: with(
                        tappedChallenge,
                        concat(
                            set(\.id, fixedID)
                        )
                    )
                ), id: tappedChallenge.id
            )
        }

        await store.send(.edit(.task))

        await store.send(.edit(.binding(.set(\.$challenge.title, "  Edited title  ")))) {
            $0.editState?.challenge.title = "  Edited title  "
        }

        await store.send(.edit(.binding(.set(\.$challenge.description, "  Edited Description  ")))) {
            $0.editState?.challenge.description = "  Edited Description  "
            $0.editState?.isComplete = true
        }

        cont.yield(.user(User.emptyRemote))
        await store.receive(.edit(.userResponse(User.emptyRemote))) {
            $0.editState?.canInviteFriends = true
        }

        await store.send(.edit(.nextButtonTapped))

        let socialGraph = SocialGraph(
            followers: [
                .fake(),
                .fake(),
                .fake(),
                .fake()
            ],
            following: []
        )
        socialGraphStream.continuation.yield(socialGraph)

        store.exhaustivity = .off
        await store.send(.edit(.inviteUsersToChallenge(.task)))
        await store.send(.edit(.inviteUsersToChallenge(.toggleSelectionTapped(socialGraph.followers[0].user.id))))
        await store.send(.edit(.inviteUsersToChallenge(.toggleSelectionTapped(socialGraph.followers[2].user.id))))

        let expectedSaveValue = SaveValue(
            challenge: with(
                tappedChallenge,
                concat(
                    set(\.id, fixedID),
                    set(\.title, "Edited title"),
                    set(\.description, "Edited Description"),
                    set(\.region, .some(userRegion))
                )
            ),
            participants: [socialGraph.followers[0].user.id, socialGraph.followers[2].user.id]
        )

        await store.send(.edit(.commitChanges)) {
            $0.editState?.shouldEndEditing = true
        }

        await savedValue.withValue { savedValue in
            XCTAssertNoDifference(expectedSaveValue, savedValue)
        }

        await store.receive(.saveResponse(.success(expectedSaveValue.challenge)))
        await store.receive(.closeEditSheet) {
            $0.editState = nil
        }

        await store.send(.challengeTapped(id: challenges[1].id)) {
            let expectedID = store.dependencies.challengeID()
            $0.editState = .init(.init(challenge: with(challenges[1], concat(
                set(\.id, expectedID)
            ))), id: challenges[1].id)
        }

        await store.send(.cancelTapped) {
            $0.editState = nil
        }
    }
}

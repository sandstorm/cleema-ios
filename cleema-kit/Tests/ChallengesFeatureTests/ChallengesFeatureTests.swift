//
//  Created by Kumpels and Friends on 23.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ChallengesFeature
import Overture
import XCTest

@MainActor
final class ChallengesFeatureTests: XCTestCase {
    func testLoadingChallenges() async throws {
        let store = TestStore(
            initialState: .init(selectRegionState: .init(selectedRegion: .pirna), userRegion: .dresden),
            reducer: Challenges()
        )

        let joinedChallenges: [JoinedChallenge] = [.fake(), .fake(), .fake()]

        let joinedChallengesStream = AsyncStream<[JoinedChallenge]>.streamWithContinuation()
        store.dependencies.challengesClient.joinedChallenges = { joinedChallengesStream.stream }

        let loadTask = await store.send(.joinedChallenges(.task))

        joinedChallengesStream.continuation.yield(joinedChallenges)

        await store.receive(.joinedChallenges(.userChallengesResponse(joinedChallenges))) {
            $0.joinedChallengesState.challenges = .init(uniqueElements: joinedChallenges)
        }

        let updated: [JoinedChallenge] = [.fake(), .fake()]
        joinedChallengesStream.continuation.yield(updated)

        await store.receive(.joinedChallenges(.userChallengesResponse(updated))) {
            $0.joinedChallengesState.challenges = .init(uniqueElements: updated)
        }

        await loadTask.cancel()
    }

    func testAddingAUserChallenge() async throws {
        var template = Challenge()
        let challengeTemplates: [Challenge] = [template, .init(), .init()]
        let userRegion: Region = .dresden
        let store = TestStore(
            initialState: .init(
                selectRegionState: .init(selectedRegion: .pirna),
                challengeTemplatesState: ChallengeTemplates.State(
                    challenges: .init(uniqueElements: challengeTemplates),
                    userRegion: userRegion,
                    editState: .init(.init(challenge: template), id: template.id)
                ), userRegion: userRegion
            ),
            reducer: Challenges()
        )
        let savedChallenge = with(template, concat(set(\.region, .some(userRegion))))
        store.dependencies.challengesClient.save = { _, _ in savedChallenge }

        template.title = "Challenge 2"

        await store.send(.challengeTemplates(.edit(.binding(.set(\.$challenge.title, "Challenge 2"))))) {
            $0.challengeTemplatesState?.editState = .init(.init(challenge: template), id: template.id)
        }

        template.description = "Challenge 2 Description"

        await store
            .send(.challengeTemplates(.edit(.binding(.set(\.$challenge.description, "Challenge 2 Description"))))) {
                $0.challengeTemplatesState?.editState = .init(.init(challenge: template), id: template.id)
            }

        let startDate = Date.beginningOf(day: 1, month: 7, year: 2_022)!
        template.startDate = startDate

        await store.send(.challengeTemplates(.edit(.binding(.set(\.$challenge.startDate, startDate))))) {
            $0.challengeTemplatesState?.editState = .init(.init(challenge: template), id: template.id)
        }

        let endDate = Date.beginningOf(day: 31, month: 7, year: 2_022)!
        template.endDate = endDate

        await store.send(.challengeTemplates(.edit(.binding(.set(\.$challenge.endDate, endDate))))) {
            $0.challengeTemplatesState?.editState = .init(.init(challenge: template), id: template.id)
        }

        await store.send(.challengeTemplates(.edit(.commitChanges))) {
            $0.challengeTemplatesState?.editState?.shouldEndEditing = true
        }

        await store.receive(.challengeTemplates(.saveResponse(.success(savedChallenge)))) {
            $0.joinedChallengesState.challenges.append(.init(challenge: savedChallenge))
        }

        await store.receive(.challengeTemplates(.closeEditSheet)) {
            $0.challengeTemplatesState = nil
        }
    }

    func testCancellation() async throws {
        let challengeTemplates: [Challenge] = [.init(), .init(), .init()]
        let store = TestStore(
            initialState: .init(
                selectRegionState: .init(selectedRegion: .pirna),
                challengeTemplatesState: ChallengeTemplates.State(
                    challenges: .init(uniqueElements: challengeTemplates),
                    userRegion: .leipzig,
                    editState: .init(.init(challenge: challengeTemplates[0]), id: challengeTemplates[0].id)
                ), userRegion: .leipzig
            ),
            reducer: Challenges()
        )

        await store.send(.challengeTemplates(.cancelTapped)) {
            $0.challengeTemplatesState = nil
        }
    }

    func testSelectUserChallenge() throws {
        let joinedChallenges = [JoinedChallenge.fake(), .fake()]
        let store = TestStore(
            initialState: .init(
                selectRegionState: .init(selectedRegion: .pirna),
                joinedChallengesState: .init(challenges: joinedChallenges),
                userRegion: .leipzig
            ),
            reducer: Challenges()
        )

        let selectedChallenge = joinedChallenges.randomElement()!

        store.send(.joinedChallenges(.setNavigation(selection: selectedChallenge.id))) {
            $0.joinedChallengesState.selection = .init(
                .init(userChallenge: selectedChallenge),
                id: selectedChallenge.id
            )
        }

        store.send(.joinedChallenges(.setNavigation(selection: nil))) {
            $0.joinedChallengesState.selection = nil
        }
    }

    func testLeavingAUserChallenge() async throws {
        let joinedChallenges = [JoinedChallenge.fake(), .fake()]
        let store = TestStore(
            initialState: .init(
                selectRegionState: .init(selectedRegion: .pirna),
                joinedChallengesState: .init(challenges: joinedChallenges),
                userRegion: .pirna
            ),
            reducer: Challenges()
        )
        let joinedChallengesStream = AsyncStream<[JoinedChallenge]>.streamWithContinuation()
        let selectedChallenge = joinedChallenges.randomElement()!
        let removedChallengeID = ActorIsolated<Challenge.ID?>(nil)
        store.dependencies.challengesClient.joinedChallenges = { joinedChallengesStream.stream }
        store.dependencies.challengesClient.leaveChallenge = {
            await removedChallengeID.setValue($0)
            return selectedChallenge.challenge
        }

        await store.send(.joinedChallenges(.setNavigation(selection: selectedChallenge.id))) {
            $0.joinedChallengesState.selection = .init(
                .init(userChallenge: selectedChallenge),
                id: selectedChallenge.id
            )
        }

        await store.send(.joinedChallenges(.userChallenge(.leaveTapped))) {
            $0.joinedChallengesState.selection?.value
                .alertState = .leave(challengeTitle: selectedChallenge.challenge.title)
        }

        await store.send(.joinedChallenges(.userChallenge(.dismissAlert))) {
            $0.joinedChallengesState.selection?.alertState = nil
        }

        await store.send(.joinedChallenges(.userChallenge(.leaveTapped))) {
            $0.joinedChallengesState.selection?.value
                .alertState = .leave(challengeTitle: selectedChallenge.challenge.title)
        }

        await store.send(.joinedChallenges(.userChallenge(.leaveConfirmationTapped)))

        await store
            .receive(.joinedChallenges(.userChallenge(.leaveChallengeResponse(.success(
                selectedChallenge
                    .challenge
            ))))) {
                $0.joinedChallengesState.selection = nil
                $0.joinedChallengesState.challenges.remove(id: selectedChallenge.id)
            }
    }

    func testFilteringPartnerChallengesToSelectedRegion() async throws {
        let store = TestStore(
            initialState: .init(
                selectRegionState: .init(selectedRegion: .pirna),
                joinedChallengesState: .init(),
                partnerChallengesState: .init(region: .pirna),
                userRegion: .leipzig
            ),
            reducer: Challenges()
        )

        store.dependencies.regionsClient.regions = { _ in
            [.leipzig, .dresden, .pirna]
        }

        let pirnaChallenges = [
            Challenge.fake(kind: .partner(.fake()), region: .pirna),
            .fake(kind: .partner(.fake()), region: .pirna)
        ]
        let leipzigChallenges = [
            Challenge.fake(kind: .partner(.fake()), region: .leipzig),
            .fake(kind: .partner(.fake()), region: .leipzig)
        ]
        let dresdenChallenges = [
            Challenge.fake(kind: .partner(.fake()), region: .dresden),
            .fake(kind: .partner(.fake()), region: .dresden)
        ]

        store.dependencies.challengesClient.partnerChallenges = { region in
            AsyncThrowingStream { continuation in
                continuation.yield(
                    (pirnaChallenges + dresdenChallenges + leipzigChallenges)
                        .filter { $0.region == region }
                )
                continuation.finish()
            }
        }

        var task = await store.send(.partnerChallenges(.task)) {
            $0.partnerChallengesState?.isLoading = true
        }

        await store.receive(.partnerChallenges(.loadResponse(.success(pirnaChallenges)))) {
            $0.partnerChallengesState?.isLoading = false
            $0.partnerChallengesState?.challenges = .init(uniqueElements: pirnaChallenges)
        }

        task = await store.send(.partnerChallenges(.setRegion(.leipzig))) {
            $0.partnerChallengesState?.region = .leipzig
        }

        await store.receive(.partnerChallenges(.task)) {
            $0.partnerChallengesState?.isLoading = true
        }

        await store.receive(.partnerChallenges(.loadResponse(.success(leipzigChallenges)))) {
            $0.partnerChallengesState?.isLoading = false
            $0.partnerChallengesState?.challenges = .init(uniqueElements: leipzigChallenges)
        }

        await task.cancel()
    }
}

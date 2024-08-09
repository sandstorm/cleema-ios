//
//  Created by Kumpels and Friends on 13.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import EditChallengeFeature
import Models
import UserClient
import XCTest

@MainActor
final class EditChallengeFeatureTests: XCTestCase {
    func testFeature() async {
        let startDate = Date()
        let store = TestStore(
            initialState: .init(challenge: .init(
                startDate: startDate,
                endDate: Calendar.current.date(byAdding: .day, value: 3, to: startDate)!
            )),
            reducer: EditChallenge()
        )

        await store.send(.binding(.set(\.$selection, .measurement))) {
            $0.selection = .measurement
        }

        await store.send(.measurement(.unitChanged(.kilograms))) {
            $0.measurementState.unit = .kilograms
            $0.challenge.type = .measurement(1, .kilograms)
        }

        await store.send(.binding(.set(\.$selection, .steps))) {
            $0.selection = .steps
        }

        await store.send(.progress(.binding(.set(\.$count, 42)))) {
            $0.progressState.count = 42
            $0.challenge.type = .steps(42)
        }

        await store.send(.binding(.set(\.$challenge.title, "A fancy title"))) {
            $0.challenge.title = "A fancy title"
        }

        await store.send(.binding(.set(\.$challenge.description, "A challenge description"))) {
            $0.challenge.description = "A challenge description"
            $0.isComplete = true
        }

        await store.send(.binding(.set(\.$challenge.title, ""))) {
            $0.challenge.title = ""
            $0.isComplete = false
        }

        await store.send(.binding(.set(\.$challenge.description, ""))) {
            $0.challenge.description = ""
        }

        await store.send(.binding(.set(\.$challenge.description, "description"))) {
            $0.challenge.description = "description"
        }

        await store.send(.binding(.set(\.$challenge.title, "title"))) {
            $0.challenge.title = "title"
            $0.isComplete = true
        }

        await store.send(.binding(.set(\.$challenge.title, "    "))) {
            $0.challenge.title = "    "
            $0.isComplete = false
        }

        await store.send(.binding(.set(\.$challenge.description, "  "))) {
            $0.challenge.description = "  "
            $0.isComplete = false
        }

        await store.send(.binding(.set(\.$challenge.interval, .weekly))) {
            $0.challenge.interval = .weekly
        }

        let date = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        await store.send(.binding(.set(\.$challenge.startDate, date))) {
            $0.challenge.startDate = date
        }

        let later = Calendar.current.date(byAdding: .day, value: 10, to: date)!
        await store.send(.binding(.set(\.$challenge.endDate, later))) {
            $0.challenge.endDate = later
        }

        await store.send(.binding(.set(\.$challenge.endDate, .distantPast))) {
            $0.challenge.endDate = $0.challenge.startDate
        }

        await store.send(.binding(.set(\.$challenge.isPublic, true))) {
            $0.challenge.isPublic = true
        }

        await store.send(.binding(.set(\.$challenge.isPublic, false))) {
            $0.challenge.isPublic = false
        }

        await store.send(.commitChanges) {
            $0.shouldEndEditing = true
        }
    }

    func testItShowsTheInvitationOfFriendsWhenInvitationIsEnabled() async {
        let startDate = Date()
        let store = TestStore(
            initialState: .init(
                challenge: .init(
                    startDate: startDate,
                    endDate: Calendar.current.date(byAdding: .day, value: 3, to: startDate)!
                ), canInviteFriends: true
            ),
            reducer: EditChallenge()
        )

        await store.send(.nextButtonTapped)

        await store.receive(.setNavigation(isActive: true)) {
            $0.inviteUsersToChallengeState = .loading
        }

        await store.send(.inviteUsersToChallenge(.saveButtonTapped))

        await store.receive(.commitChanges) {
            $0.shouldEndEditing = true
        }
    }

    func testItDoesNotShowsTheInvitationOfFriendsWhenInvitationIsEnabled() async {
        let startDate = Date()
        let store = TestStore(
            initialState: .init(
                challenge: .init(
                    startDate: startDate,
                    endDate: Calendar.current.date(byAdding: .day, value: 3, to: startDate)!
                ), canInviteFriends: false
            ),
            reducer: EditChallenge()
        )

        await store.send(.nextButtonTapped)

        await store.receive(.commitChanges) {
            $0.shouldEndEditing = true
        }
    }

    func testUsersFromClientWillSetTheCanInviteUsersState() async {
        let startDate = Date()
        let (userStream, currentUserCont) = AsyncStream<UserValue?>.streamWithContinuation()
        let store = TestStore(
            initialState: .init(
                challenge: .init(
                    startDate: startDate,
                    endDate: Calendar.current.date(byAdding: .day, value: 3, to: startDate)!
                ), canInviteFriends: false
            ),
            reducer: EditChallenge()
        ) {
            $0.userClient.userStream = { userStream }
        }

        let task = await store.send(.task)

        currentUserCont.yield(.user(User.emptyRemote))

        await store.receive(.userResponse(User.emptyRemote)) {
            $0.canInviteFriends = true
        }

        currentUserCont.yield(.user(.empty))

        await store.receive(.userResponse(.empty)) {
            $0.canInviteFriends = false
        }

        await task.cancel()
    }

    func testIsCompleteFromChallenge() {
        XCTAssertFalse(EditChallenge.State(challenge: .init(title: "", description: "")).isComplete)
        XCTAssertFalse(EditChallenge.State(challenge: .init(title: "Title", description: "")).isComplete)
        XCTAssertFalse(EditChallenge.State(challenge: .init(title: "", description: "Description")).isComplete)
        XCTAssertTrue(EditChallenge.State(challenge: .init(title: "Title", description: "Description")).isComplete)
    }
}

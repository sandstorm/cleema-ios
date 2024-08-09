//
//  Created by Kumpels and Friends on 06.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import DashboardFeature
import DashboardGridFeature
import Fakes
import Models
import Overture
import SwiftUI
import UserChallengeFeature
import UserClient
import XCTest
import XCTestDynamicOverlay

@MainActor
final class DashboardFeatureTests: XCTestCase {
    func testFeature() async throws {
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let socialID = UUID(uuidString: "883867e5-ffc9-4556-a2ab-d3c548244ff5")!
        let user = User(
            name: "user",
            region: .pirna,
            joinDate: .now,
            followerCount: Int.random(in: 1 ... 100),
            followingCount: Int.random(in: 0 ... 10),
            referralCode: "code"
        )
        let projects: [Project] = [
            .fake(isFaved: true),
            .fake(goal: .funding(currentAmount: 1, totalAmount: 32), isFaved: false),
            .fake(isFaved: true),
            .fake(goal: .involvement(currentParticipants: 1, maxParticipants: 1, joined: true)),
            .fake(goal: .involvement(currentParticipants: 1, maxParticipants: 1, joined: false), isFaved: false)
        ]
        let expectedProjects: [Project] = [projects[0], projects[2], projects[3]]

        let store = TestStore(
            initialState: .init(gridState: .init()),
            reducer: Dashboard()
        ) {
            $0.uuid = .constant(socialID)
            $0.projectsClient.projects = { _ in projects }
            $0.userClient.userStream = { userStream }
        }

        let task = await store.send(.grid(.task)) {
            $0.gridState.isLoading = true
        }
        userContinuation.yield(.user(user))

        await store.receive(.grid(.userResult(user))) {
            $0.gridState.user = user
        }

        await store
            .receive(.grid(.contentResponse(.success(.init(
                projects: expectedProjects,
                socialItems: [SocialItem(
                    id: .init(socialID),
                    title: DashboardGridFeature.L10n.Invite.title,
                    text: DashboardGridFeature.L10n.Invite.followerCount(user.followerCount),
                    badgeNumber: user.followerCount
                )]
            ))))) {
                $0.gridState.isLoading = false
                $0.gridState.firstRow = [
                    .init(
                        content: .social(SocialItem(
                            id: .init(socialID),
                            title: DashboardGridFeature.L10n.Invite.title,
                            text: DashboardGridFeature.L10n.Invite.followerCount(user.followerCount),
                            badgeNumber: user.followerCount
                        )),
                        isWaveMirrored: false
                    ),
                    .init(content: .project(expectedProjects[0]), isWaveMirrored: true),
                    .init(content: .project(expectedProjects[1]), isWaveMirrored: false),
                    .init(content: .project(expectedProjects[2]), isWaveMirrored: true)
                ]

                $0.gridState.secondRow = []
            }

        let project = expectedProjects[1]
        store.dependencies.projectsClient.fav = { _, _ in project }
        await store.send(.grid(.setNavigation(selection: project.id.rawValue))) {
            $0.gridState.selection = Identified(.project(.init(project: project)), id: project.id.rawValue)
        }

        await store.send(.grid(.project(.favoriteTapped))) {
            $0.gridState.selection = Identified(
                .project(.init(project: project, isLoading: true)),
                id: project.id.rawValue
            )

            $0.gridState.firstRow[id: project.id.rawValue]?
                .content = .project(project)
        }
        await store.receive(.grid(.project(.projectResponse(.success(project))))) {
            $0.gridState.selection = Identified(
                .project(.init(project: project, isLoading: false)),
                id: project.id.rawValue
            )
        }

        await store.send(.grid(.project(.favoriteTapped))) {
            $0.gridState.selection = Identified(
                .project(.init(project: project, isLoading: true)),
                id: project.id.rawValue
            )
        }

        await store.receive(.grid(.project(.projectResponse(.success(project))))) {
            $0.gridState.selection = Identified(
                .project(.init(project: project, isLoading: false)),
                id: project.id.rawValue
            )
        }

        await store.send(.grid(.setNavigation(selection: nil))) {
            $0.gridState.selection = nil
        }

        await task.cancel()
    }

    func testNoFavedProjects() async throws {
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let socialID = UUID(uuidString: "883867e5-ffc9-4556-a2ab-d3c548244ff5")!
        let expectedSocialItems: [SocialItem] = [
            SocialItem(
                id: .init(socialID),
                title: DashboardGridFeature.L10n.Invite.title,
                text: DashboardGridFeature.L10n.Invite.followerCount(0),
                badgeNumber: 0
            )
        ]

        let user = User(
            name: "user",
            region: .pirna,
            joinDate: .now,
            followerCount: 0,
            followingCount: Int.random(in: 0 ... 10),
            referralCode: "code"
        )
        let store = TestStore(
            initialState: .init(gridState: .init()),
            reducer: Dashboard()
        ) {
            $0.uuid = .constant(socialID)
            $0.projectsClient.projects = { _ in [] }
            $0.userClient.userStream = { userStream }
        }

        let task = await store.send(.grid(.task)) {
            $0.gridState.isLoading = true
        }
        userContinuation.yield(.user(user))

        await store.receive(.grid(.userResult(user))) {
            $0.gridState.user = user
        }

        await store.receive(.grid(.contentResponse(.success(.init(projects: [], socialItems: expectedSocialItems))))) {
            $0.gridState.isLoading = false
            $0.gridState.firstRow = [
                .init(
                    content: .social(SocialItem(
                        id: .init(socialID),
                        title: DashboardGridFeature.L10n.Invite.title,
                        text: DashboardGridFeature.L10n.Invite.followerCount(0),
                        badgeNumber: 0
                    )),
                    isWaveMirrored: false
                )
            ]
        }

        await task.cancel()
    }
}

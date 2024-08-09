//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models
import Overture
import ProjectDetailFeature
import ProjectsClient
import XCTest

@MainActor
final class ProjectDetailFeatureTests: XCTestCase {
    var spy: ProjectsClientSpy!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
        spy = .init()
    }

    @MainActor override func tearDownWithError() throws {
        spy = nil
        try super.tearDownWithError()
    }

    func testFlow() async throws {
        struct TestError: Error, Equatable {}
        let project: Project = .fake(
            title: "Project",
            goal: .involvement(currentParticipants: 3, maxParticipants: 42, joined: false),
            phase: .pre
        )
        let store = TestStore(
            initialState: .init(project: project, isLoading: false),
            reducer: ProjectDetail()
        ) {
            $0.log = .noop
            $0.projectsClient = spy.client
        }

        let expectedProject = Project.fake(
            title: "Project",
            goal: .involvement(currentParticipants: 3, maxParticipants: 42, joined: true),
            phase: .pre
        )
        spy.joinResult = .success(expectedProject)

        await store.send(.engageButtonTapped) {
            $0.isLoading = true
        }
        XCTAssertEqual(.join(project.id), spy.entries.last)

        await store.receive(.projectResponse(.success(expectedProject))) {
            $0.isLoading = false
            $0.project = expectedProject
        }

        spy.reset()

        await store.send(.engageButtonTapped) {
            $0.alertState = .leave(title: expectedProject.title)
        }

        await store.send(.dismissAlert) {
            $0.alertState = nil
        }

        await store.send(.engageButtonTapped) {
            $0.alertState = .leave(title: expectedProject.title)
        }

        let leftProject = Project.fake(
            title: "Project",
            goal: .involvement(currentParticipants: 3, maxParticipants: 42, joined: false),
            phase: .pre
        )
        spy.leftResult = .success(leftProject)

        await store.send(.leaveConfirmationTapped) {
            $0.alertState = nil
            $0.isLoading = true
        }
        XCTAssertEqual(.leave(expectedProject.id), spy.entries.last)

        await store.receive(.projectResponse(.success(leftProject))) {
            $0.isLoading = false
            $0.project = leftProject
        }

        spy.reset()
        spy.joinResult = .failure(TestError())

        await store.send(.engageButtonTapped) {
            $0.isLoading = true
        }
        XCTAssertEqual(.join(leftProject.id), spy.entries.last)

        await store.receive(.projectResponse(.failure(TestError()))) {
            $0.isLoading = false
        }
    }

    func testJoiningAProjectWithCompleteParticipantsIsNotPossible() async throws {
        struct TestError: Error, Equatable {}
        let project: Project = .fake(
            title: "Project",
            goal: .involvement(currentParticipants: 42, maxParticipants: 42, joined: false)
        )
        let store = TestStore(
            initialState: .init(project: project, isLoading: false),
            reducer: ProjectDetail()
        )

        await store.send(.engageButtonTapped)
    }

    func testLeavingAProjectWithCompleteParticipantsIsPossible() async throws {
        struct TestError: Error, Equatable {}
        let project: Project = .fake(
            title: "Project",
            goal: .involvement(currentParticipants: 10, maxParticipants: 10, joined: true),
            phase: .pre
        )
        let store = TestStore(
            initialState: .init(project: project, isLoading: false),
            reducer: ProjectDetail()
        ) {
            $0.projectsClient = spy.client
        }

        await store.send(.engageButtonTapped) {
            $0.alertState = .leave(title: project.title)
        }

        await store.send(.leaveConfirmationTapped) {
            $0.alertState = nil
            $0.isLoading = true
        }

        XCTAssertEqual(.leave(project.id), spy.entries.last)

        let expectedProject = try XCTUnwrap(spy.leftResult.get())
        await store.receive(.projectResponse(.success(expectedProject))) {
            $0.isLoading = false
            $0.project = expectedProject
        }
    }

    func testIntegrationOfFundingFeature() async throws {
        let project: Project = .fake(
            title: "Project",
            goal: .funding(currentAmount: 1, totalAmount: 8_000)
        )
        let store = TestStore(
            initialState: .init(project: project, isLoading: false),
            reducer: ProjectDetail()
        )
        store.dependencies.projectsClient.support = { id, value in }

        let expectedAmount = 42
        await store.send(.funding(.steps(.amount(.binding(.set(\.$amount, expectedAmount)))))) {
            $0.fundingState?.step = .amount(.custom(expectedAmount))
        }

        await store.send(.funding(.steps(.amount(.supportTapped)))) {
            $0.fundingState?.step = .pending
        }

        await store.receive(.funding(.supportResponse(.success(expectedAmount)))) {
            $0.fundingState?.step = .donation(amount: expectedAmount)
            $0.project.goal = .funding(currentAmount: 1 + expectedAmount, totalAmount: 8_000)
            $0.fundingState?.currentAmount = 1 + expectedAmount
        }
    }

    func testFavingAProject() async throws {
        let project: Project = .fake(title: "Project", isFaved: false)
        let expected = Project.fake(title: "Faved project")
        spy.favResult = .success(expected)
        let store = TestStore(
            initialState: .init(project: project, isLoading: false),
            reducer: ProjectDetail()
        ) { $0.projectsClient = spy.client }

        await store.send(.favoriteTapped) {
            $0.isLoading = true
        }

        await store.receive(.projectResponse(.success(expected))) {
            $0.project = expected
            $0.isLoading = false
        }

        XCTAssertEqual(.fav(project.id, true), spy.entries.last)
    }

    func testJoiningAProjectInPrePhaseIsPossible() async throws {
        struct TestError: Error, Equatable {}

        let project: Project = .fake(
            title: "Project",
            goal: .involvement(currentParticipants: 42, maxParticipants: 43, joined: false),
            phase: .pre
        )

        XCTAssertTrue(project.canEngage)
    }

    func testJoiningAProjectNotInPrePhaseIsNotPossible() async throws {
        struct TestError: Error, Equatable {}

        for phase in Project.Phase.allCases.filter({ $0 != .pre }) {
            let project: Project = .fake(
                title: "Project",
                goal: .involvement(currentParticipants: 42, maxParticipants: 43, joined: false),
                phase: phase
            )

            XCTAssertFalse(project.canEngage)
        }
    }
}

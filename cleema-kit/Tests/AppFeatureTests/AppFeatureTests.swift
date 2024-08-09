//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import AppFeature
import DeepLinking
import Models
import Overture
import ProfileFeature
import QuizFeature
import UserFavoritesFeature
import XCTest

@MainActor
final class AppFeatureTests: XCTestCase {
    func testProfileFlow() async throws {
        let date = Date()
        let uuid = UUID()
        let user = User(name: "user", region: .pirna, joinDate: .now, referralCode: "pirna")
        let expected = [Trophy(id: .init(rawValue: uuid), date: date, title: "Foo", image: .fake())]

        var expectedProfileState = Profile.State()
        var destination = App.Destination.sheet(.profile(expectedProfileState))

        let store = TestStore(
            initialState: .init(
                newsState: .init(searchState: .init(region: Region.leipzig.id)),
                projectsState: .init(selectRegionState: .init(selectedRegion: .pirna)),
                challengesState: .init(selectRegionState: .init(selectedRegion: .pirna), userRegion: user.region),
                marketplaceState: .init(selectRegionState: .init(selectedRegion: .pirna)),
                destination: destination
            ),
            reducer: App()
        ) {
            $0.date = .constant(date)
            $0.uuid = .constant(uuid)
            $0.trophyClient.loadTrophies = { expected }
        }

        expectedProfileState.trophiesFeatureState.isLoading = true
        destination = App.Destination.sheet(.profile(expectedProfileState))

        await store.send(.profile(.trophies(.load))) {
            $0.destination = destination
        }

        expectedProfileState.trophiesFeatureState = .init(trophies: .init(uniqueElements: expected))
        destination = App.Destination.sheet(.profile(expectedProfileState))

        await store.receive(.profile(.trophies(.loadResponse(.success(expected))))) {
            $0.destination = destination
        }

        await store.send(.dismissDestination) {
            $0.destination = nil
        }
    }

    func testPresentingProfileSheet() async throws {
        let user = User(name: "user", region: .pirna, joinDate: .now, referralCode: "pirna")
        let store = TestStore(
            initialState: .init(user: user),
            reducer: App()
        )

        for action in [
            App.Action.dashboard(.profileButtonTapped),
            .news(.profileButtonTapped),
            .projects(.profileButtonTapped),
            .challenges(.profileButtonTapped),
            .marketplace(.profileButtonTapped)
        ] {
            await store.send(action) {
                $0.destination = App.Destination.sheet(.profile(Profile.State()))
            }

            await store.send(.dismissDestination) {
                $0.destination = nil
            }
        }
    }

    func testFavoritingAProjectInProfileSheetWillUpdateTheProjectsState() async throws {
        let user = User(name: "user", region: .pirna, joinDate: .now, referralCode: "pirna")
        let project = Project.fake(goal: .information, isFaved: false)
        let favedProject = Project.fake(id: project.id, goal: .information, isFaved: true)

        var expectedProfileState = Profile.State(
            userFavoritesState: .init(
                selection: .init(
                    UserFavorites.State.Item.project(.init(project: project)),
                    id: project.id.rawValue
                )
            )
        )
        let destination = App.Destination.sheet(.profile(expectedProfileState))

        let store = TestStore(
            initialState: .init(
                newsState: .init(searchState: .init(region: Region.leipzig.id)),
                projectsState: .init(
                    projects: [.init(project: project)],
                    selectRegionState: .init(selectedRegion: .pirna)
                ),
                challengesState: .init(selectRegionState: .init(selectedRegion: .pirna), userRegion: user.region),
                marketplaceState: .init(selectRegionState: .init(selectedRegion: .pirna)),
                destination: destination
            ),
            reducer: App()
        ) {
            $0.projectsClient.fav = { _, _ in favedProject }
        }

        expectedProfileState.userFavoritesState.selection?.value = .project(.init(project: project, isLoading: true))
        await store.send(.profile(.userFavorites(.projectDetail(.favoriteTapped)))) {
            $0.destination = App.Destination.sheet(.profile(expectedProfileState))
        }

        expectedProfileState.userFavoritesState.selection?
            .value = .project(.init(project: favedProject, isLoading: false))
        await store.receive(.profile(.userFavorites(.projectDetail(.projectResponse(.success(favedProject)))))) {
            $0.destination = App.Destination.sheet(.profile(expectedProfileState))
            $0.projectsState.projects[id: favedProject.id]?.project.isFaved = favedProject.isFaved
        }
    }

    func testPresentingInfoSheet() async throws {
        let store = TestStore(
            initialState: .init(user: .init(name: "user", region: .pirna, joinDate: .now, referralCode: "pirna")),
            reducer: App()
        )

        await store.send(.dashboard(.infoButtonTapped(.about))) {
            $0.destination = .sheet(.info(.init(id: .about)))
        }

        await store.send(.dismissDestination) {
            $0.destination = nil
        }
    }

    func testHandleInvitationLinkWithRemoteUser() async throws {
        let expectedSocialGraphItem: SocialGraphItem = .fake()
        let usedReferralCode = ActorIsolated<String?>(nil)
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let user = User(
            name: "user",
            region: .pirna,
            joinDate: .now,
            kind: .remote(password: "", email: ""),
            referralCode: "pirna"
        )

        let store = TestStore(
            initialState: .init(user: user),
            reducer: App()
        ) {
            $0.log = .noop
            $0.deepLinkingClient.routeForURL = { _ in AppRoute.invitation("deadbeef") }
            $0.userClient.followInvitation = { referralCode in
                await usedReferralCode.setValue(referralCode)
                return expectedSocialGraphItem
            }
            $0.userClient.userStream = { userStream }
        }
        store.exhaustivity = .off

        let task = await store.send(.task)
        userContinuation.yield(.user(user))
        await store.receive(.userResult(user))

        await store.send(.handleAppRoute(.invitation("deadbeef")))

        await usedReferralCode.withValue { code in XCTAssertEqual("deadbeef", code) }

        await store.receive(.followInvitationResponse(.success(expectedSocialGraphItem))) {
            $0.destination = .dialog(.acceptInvitation(expectedSocialGraphItem.user))
        }

        await store.receive(.handleAppRouteResponse)

        await task.cancel()
    }

    func testHandleInvitationLinkWithLocalUser() async throws {
        struct TestError: Error, Equatable {}
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let user = User(
            name: "user",
            region: .pirna,
            joinDate: .now,
            kind: .local,
            referralCode: "pirna"
        )
        let store = TestStore(
            initialState: .init(user: user),
            reducer: App()
        ) {
            $0.userClient.userStream = { userStream }
        }
        store.exhaustivity = .off

        let task = await store.send(.task)
        userContinuation.yield(.user(user))
        await store.receive(.userResult(user))

        await store.send(.handleAppRoute(.invitation("0815"))) {
            $0.destination = .alert(.followInvitationNotPossible)
        }
        await store.receive(.handleAppRouteResponse)

        await task.cancel()
    }

    func testTapSocialItemOnDashboardForRemoteUser() async throws {
        let url = URL(string: "https://localhost/invites/foo-bar")!
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let user = User.emptyRemote

        let store = TestStore(
            initialState: .init(user: user),
            reducer: App()
        ) {
            $0.deepLinkingClient.urlForRoute = { _ in
                url
            }
            $0.userClient.userStream = { userStream }
        }
        store.exhaustivity = .off

        let task = await store.send(.task)
        userContinuation.yield(.user(user))
        await store.receive(.userResult(user))

        await store.send(.dashboard(.grid(.socialItemTapped))) {
            $0.destination = .dialog(.invite)
        }

        await store.send(.dismissDestination) {
            $0.destination = nil
        }

        await store.send(.dashboard(.grid(.socialItemTapped))) {
            $0.destination = .dialog(.invite)
        }

        await store.send(.invitationButtonTapped) {
            $0.destination = .sheet(.inviteActivity(url))
        }

        await task.cancel()
    }

    func testTapSocialItemOnDashboardForLocalUser() async throws {
        let url = URL(string: "https://localhost/invites/")!
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        let user = User.empty

        let store = TestStore(
            initialState: .init(user: user),
            reducer: App()
        ) {
            $0.deepLinkingClient.urlForRoute = { _ in
                url
            }
            $0.userClient.userStream = { userStream }
        }
        store.exhaustivity = .off

        let task = await store.send(.task)
        userContinuation.yield(.user(user))
        await store.receive(.userResult(user))

        await store.send(.dashboard(.grid(.socialItemTapped))) {
            $0.destination = .dialog(.invite)
        }

        await store.send(.dismissDestination) {
            $0.destination = nil
        }

        await store.send(.dashboard(.grid(.socialItemTapped))) {
            $0.destination = .dialog(.invite)
        }

        await store.send(.invitationButtonTapped) {
            $0.destination = .sheet(.inviteActivity(url))
        }

        await task.cancel()
    }

    func testEditingAcceptsSurveysUpdatesSurveysState() async throws {
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        var user = User.emptyRemote
        user.avatar = .fake()
        user.acceptsSurveys = false
        let store = TestStore(
            initialState: .init(user: user, destination: .sheet(.profile(.init()))),
            reducer: App()
        ) {
            $0.userClient.userStream = { userStream }
        }

        store.exhaustivity = .off

        let task = await store.send(.profile(.profileData(.user(.task))))
        userContinuation.yield(.user(user))
        await store.receive(.profile(.profileData(.user(.userResult(user)))))

        var expectedUser = user
        expectedUser.acceptsSurveys = false

        await store.send(.profile(.editProfileButtonTapped))
        await store.send(.profile(.profileData(.editProfile(.binding(.set(\.$editedUser.acceptsSurveys, true))))))

        await store.send(.profile(.profileData(.editProfile(.saveResult(.success(expectedUser)))))) {
            $0.surveysState.userAcceptedSurveys = expectedUser.acceptsSurveys
        }

        await task.cancel()
    }

    func testEditingUserRegionInProfileUpdatesNewsSearchRegion() async throws {
        let (userStream, userContinuation) = AsyncStream<UserValue?>.streamWithContinuation()
        var user = User.emptyRemote
        user.avatar = .fake()
        user.region = .leipzig

        let store = TestStore(
            initialState: .init(user: user, destination: .sheet(.profile(.init()))),
            reducer: App()
        ) {
            $0.userClient.userStream = { userStream }
            $0.newsClient.news = { _, _ in [.fake(), .fake(), .fake()] }
            $0.newsClient.tags = { [.fake(), .fake()] }
        }

        XCTAssertEqual(user.region.id, store.state.newsState.searchState.region)

        store.exhaustivity = .off

        let task = await store.send(.profile(.profileData(.user(.task))))
        userContinuation.yield(.user(user))
        await store.receive(.profile(.profileData(.user(.userResult(user)))))

        user.region = .pirna

        await store.send(.profile(.editProfileButtonTapped))
        await store.send(.profile(.profileData(.editProfile(.binding(.set(\.$editedUser.region, .pirna))))))

        await store.send(.profile(.profileData(.editProfile(.saveResult(.success(user)))))) {
            $0.newsState.searchState.region = Region.pirna.id
        }

        await store.send(.news(.load))

        await task.cancel()
    }

    func testSwitchingTabs() async throws {
        let news = [News.fake(), .fake(), .fake()]
        let tags = [Tag.fake(), .fake()]
        let projects: [Project] = [
            .fake(isFaved: true)
        ]
        let store = TestStore(
            initialState: .init(user: .emptyRemote),
            reducer: App()
        ) {
            $0.newsClient.news = { _, _ in news }
            $0.newsClient.tags = { tags }
            $0.projectsClient.projects = { _ in projects }
        }

        store.exhaustivity = .off

        XCTAssertEqual(.dashboard, store.state.selectedSection)

        await store.send(.selectSection(.news)) {
            $0.selectedSection = .news
        }

        await store.send(.news(.load)) {
            $0.newsState.isLoading = true
        }

        await store.receive(.news(.loadingResponse(.success(news)))) {
            $0.newsState.isLoading = false
            $0.newsState.news = .init(uniqueElements: news)
        }

        await store.send(.news(.setNavigation(selection: news[0].id))) {
            $0.newsState.selection = Identified(news[0], id: news[0].id)
        }

        await store.send(.selectSection(.news))

        await store.receive(.news(.setNavigation(selection: nil))) {
            $0.newsState.selection = nil
        }

//        await store.send(.selectSection(.dashboard)) {
//            $0.selectedSection = .dashboard
//        }
//
//        let task = await store.send(.dashboard(.grid(.task)))
//
//        await store.receive(.dashboard(.grid(.contentResponse(.success(.init(projects: projects, socialItems: []))))))
//
//        await store.send(.dashboard(.grid(.setNavigation(selection: projects[0].id.rawValue)))) {
//            $0.dashboardGridState.selection = Identified(.project(.init(project: projects[0])), id:
//            projects[0].id.rawValue)
//        }
//
//        await task.cancel()
    }
}

extension App.State {
    init(user: User, destination: App.Destination? = nil) {
        self.init(
            surveysState: .init(userAcceptedSurveys: user.acceptsSurveys),
            dashboardGridState: .init(),
            newsState: .init(searchState: .init(region: user.region.id)),
            projectsState: .init(selectRegionState: .init(
                selectedRegion: user.region
            )),
            challengesState: .init(selectRegionState: .init(
                selectedRegion: user.region
            ), userRegion: user.region),
            marketplaceState: .init(selectRegionState: .init(
                selectedRegion: user.region
            )),
            selectedSection: .dashboard,
            destination: destination
        )
    }
}

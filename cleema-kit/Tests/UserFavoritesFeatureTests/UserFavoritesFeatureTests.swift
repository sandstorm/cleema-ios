//
//  Created by Kumpels and Friends on 16.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Algorithms
import ComposableArchitecture
import Foundation
import Overture
import UserFavoritesFeature
import XCTest

@MainActor
final class UserFavoritesFeatureTests: XCTestCase {
    func testFavingProjectsInTheDetailSheet() async throws {
        let projects: [Project] = [
            .fake(goal: .involvement(currentParticipants: 1, maxParticipants: 32, joined: true), isFaved: true),
            .fake(goal: .information, isFaved: true),
            .fake(goal: .involvement(currentParticipants: 1, maxParticipants: 32, joined: false), isFaved: true)
        ]
        let favedProject = Project.fake(goal: .information)

        let (projectsStream, projectsCont) = AsyncThrowingStream<[Project], Error>.streamWithContinuation()
        let (newsStream, _) = AsyncThrowingStream<[News], Error>.streamWithContinuation()
        let store = TestStore(initialState: .init(), reducer: UserFavorites()) {
            $0.projectsClient.favedProjectsStream = { projectsStream }
            $0.newsClient.favedNewsStream = { newsStream }
            $0.projectsClient.fav = { _, _ in favedProject }
        }

        let task = await store.send(.load) {
            $0.isLoading = true
        }

        projectsCont.yield(projects)
        await store.receive(.projectsResponse(projects)) {
            $0.isLoading = false
            $0.items = .init(
                uniqueElements:
                projects.map { .project(.init(project: $0, isLoading: false)) }
            )
        }

        let selectedProject = projects[0]

        await store.send(.select(selectedProject.id.rawValue)) {
            $0.selection = .init(
                .project(.init(project: selectedProject, isLoading: false)),
                id: selectedProject.id.rawValue
            )
        }

        await store.send(.projectDetail(.favoriteTapped)) {
            $0.selection?
                .value =
                .project(.init(project: selectedProject, isLoading: true))
        }

        await store.receive(.projectDetail(.projectResponse(.success(favedProject)))) {
            $0.selection?
                .value =
                .project(.init(project: favedProject, isLoading: false))
        }

        await store.send(.select(nil)) {
            $0.selection = nil
        }

        await task.cancel()
    }

    func testFavingNewsInDetail() async throws {
        let favedNews = News.fake()
        let news: [News] = [.fake(isFaved: true)]

        let (projectsStream, _) = AsyncThrowingStream<[Project], Error>.streamWithContinuation()
        let (newsStream, newsCont) = AsyncThrowingStream<[News], Error>.streamWithContinuation()
        let store = TestStore(initialState: .init(), reducer: UserFavorites()) {
            $0.projectsClient.favedProjectsStream = { projectsStream }
            $0.newsClient.favedNewsStream = { newsStream }
            $0.newsClient.fav = { _, _ in favedNews }
        }

        let task = await store.send(.load) {
            $0.isLoading = true
        }

        newsCont.yield(news)
        await store.receive(.newsResponse(news)) {
            $0.isLoading = false
            $0.items.append(contentsOf: news.map { .news($0) })
        }

        let selectedNews = news[0]

        await store.send(.select(selectedNews.id.rawValue)) {
            $0.selection = .init(.news(selectedNews), id: selectedNews.id.rawValue)
        }

        await store.send(.newsDetail(.favoriteTapped))

        await store.receive(.newsDetail(.singleNewsResponse(.success(favedNews)))) {
            $0.selection?.value = .news(favedNews)
        }

        await store.send(.select(nil)) {
            $0.selection = nil
        }

        await task.cancel()
    }
}

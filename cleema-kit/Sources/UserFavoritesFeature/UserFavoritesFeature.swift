//
//  Created by Kumpels and Friends on 21.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import AsyncAlgorithms
import ComposableArchitecture
import Foundation
import Models
import NewsClient
import NewsFeature
import ProjectDetailFeature

public struct UserFavorites: ReducerProtocol {
    public struct State: Equatable {
        public enum Item: Equatable {
            case project(ProjectDetail.State)
            case news(NewsDetail.State)
        }

        public var items: IdentifiedArrayOf<Item> = []
        public var selection: Identified<Item.ID, Item>?
        public var isLoading = false

        public init(
            items: IdentifiedArrayOf<Item> = [],
            selection: Identified<Item.ID, Item>? = nil,
            isLoading: Bool = false
        ) {
            self.items = items
            self.selection = selection
            self.isLoading = isLoading
        }
    }

    public enum Action: Equatable {
        case load
        case select(State.Item.ID?)
        case projectsResponse([Project])
        case newsResponse([News])
        case projectDetail(ProjectDetail.Action)
        case newsDetail(NewsDetail.Action)
    }

    @Dependency(\.projectsClient) var projectsClient
    @Dependency(\.newsClient) var newsClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .load:
                state.isLoading = true
                return .run { send in
                    await withThrowingTaskGroup(of: Void.self) { group in
                        group.addTask {
                            for try await projects in projectsClient.favedProjectsStream() {
                                await send(.projectsResponse(projects))
                            }
                        }
                        group.addTask {
                            for try await news in newsClient.favedNewsStream() {
                                await send(.newsResponse(news))
                            }
                        }
                    }
                }
            case let .projectsResponse(projects):
                let others = state.items.filter {
                    guard case .project = $0 else { return true }
                    return false
                }
                state.items = projects.map { .project(ProjectDetail.State(project: $0, isLoading: false)) } + others
                state.isLoading = false
                return .none
            case let .newsResponse(news):
                state.isLoading = false
                let others = state.items.filter {
                    guard case .news = $0 else { return true }
                    return false
                }
                state.isLoading = false
                state.items = others + news.map { .news($0) }
                return .none
            case let .select(itemID?):
                guard let item = state.items[id: itemID] else { return .none }
                state.selection = Identified(item, id: itemID)
                return .none
            case .select(nil):
                state.selection = nil
                return .none
            case .projectDetail:
                return .none
            case .newsDetail:
                return .none
            }
        }
        .ifLet(\.selection, action: /Action.projectDetail) {
            Scope(state: \Identified.value, action: .self) {
                Scope(
                    state: /State.Item.project,
                    action: .self
                ) {
                    ProjectDetail()
                }
            }
        }
        .ifLet(\.selection, action: /Action.newsDetail) {
            Scope(state: \Identified.value, action: .self) {
                Scope(
                    state: /State.Item.news,
                    action: .self
                ) {
                    NewsDetail()
                }
            }
        }
    }
}

extension UserFavorites.State.Item: Identifiable {
    public var id: UUID {
        switch self {
        case let .project(project):
            return project.project.id.rawValue
        case let .news(news):
            return news.id.rawValue
        }
    }
}

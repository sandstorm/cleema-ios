//
//  Created by Kumpels and Friends on 10.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Fakes
import Foundation
import Logging
import Models
import NewsClient

// MARK: - State

public struct AllNews: ReducerProtocol {
    public struct State: Equatable {
        public var news: IdentifiedArrayOf<News>
        public var isLoading: Bool
        public var searchState: Search.State
        public var selection: Identified<News.ID, NewsDetail.State>?

        public init(
            news: IdentifiedArrayOf<News> = [],
            isLoading: Bool = false,
            searchState: Search.State,
            selection: Identified<News.ID, NewsDetail.State>? = nil
        ) {
            self.news = news
            self.isLoading = isLoading
            self.searchState = searchState
            self.selection = selection
        }
    }

    // MARK: - Actions

    public enum Action: Equatable {
        case load
        case loadingResponse(TaskResult<[News]>)
        case tagsResponse(TaskResult<[Tag]>)
        case news(id: News.ID, action: NewsDetail.Action)
        case profileButtonTapped
        case search(Search.Action)
        case setNavigation(selection: News.ID?)
        case newsDetail(NewsDetail.Action)
    }

    @Dependency(\.newsClient.news) var news
    @Dependency(\.newsClient.tags) var tags
    @Dependency(\.log) var log

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(
            state: \.searchState,
            action: /Action.search
        ) {
            Search()
        }

        Reduce { state, action in
            enum LoadID {}
            switch action {
            case .load:
                state.isLoading = true
                return .merge(
                    .task { [term = state.searchState.term, region = state.searchState.region] in
                        await .loadingResponse(.init {
                            try await news(term, region)
                        })
                    },
                    .task {
                        await .tagsResponse(.init {
                            try await tags()
                        })
                    }
                )
                .cancellable(id: LoadID.self, cancelInFlight: true)
                .animation(state.news.isEmpty ? nil : .spring())
            case let .loadingResponse(.success(news)):
                state.isLoading = false
                state.news = .init(uniqueElements: news)
                return .none
            case let .tagsResponse(.success(tags)):
                state.searchState.suggestionState.tags = tags
                    .sorted { $0.value.localizedCompare($1.value) == .orderedAscending }
                return .none
            case let .tagsResponse(.failure(error)), let .loadingResponse(.failure(error)):
                // TODO: handle errors
                return .fireAndForget {
                    log.info("Error loading news", userInfo: error.logInfo)
                }
            case let .news(_, .tagTapped(tag)):
                state.searchState.term = tag.value
                return .task { .load }
            case let .news(id, .tapped):
                return .task {
                    .setNavigation(selection: id)
                }
            case .profileButtonTapped:
                return .none
            case .search(.submit):
                return .task { .load }
            case .search:
                return .none
            case let .setNavigation(selection: .some(newsID)):
                guard let news = state.news[id: newsID] else { return .none }
                state.selection = Identified(news, id: newsID)
                return .none
            case .setNavigation(selection: .none):
                state.selection = nil
                return .none
            case .newsDetail:
                return .none
            case let .news(id, .favoriteTapped):
                guard let faved = state.news[id: id]?.isFaved else { return .none }
                state.news[id: id]?.isFaved = !faved
                return .none
            case .news:
                return .none
            }
        }
        .forEach(\.news, action: /Action.news(id:action:)) {
            NewsDetail()
        }
        .ifLet(\.selection, action: /Action.newsDetail) {
            Scope(state: \Identified.value, action: .self) {
                NewsDetail()
            }
        }
    }
}

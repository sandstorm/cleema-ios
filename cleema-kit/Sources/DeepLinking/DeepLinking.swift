//
//  Created by Kumpels and Friends on 29.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Logging
import Models
import UserClient

public struct DeepLinking: ReducerProtocol {
    public struct State: Equatable {
        public var matchedRoute: AppRoute?

        public init(matchedRoute: AppRoute? = nil) {
            self.matchedRoute = matchedRoute
        }
    }

    public enum Action: Equatable {
        case handleDeepLink(URL)
        case matchedRoute(TaskResult<AppRoute>)
    }

    @Dependency(\.log) private var log
    @Dependency(\.deepLinkingClient) private var deepLinkingClient

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .handleDeepLink(url):
            return .task {
                await .matchedRoute(
                    TaskResult {
                        try deepLinkingClient.routeForURL(url)
                    }
                )
            }
        case let .matchedRoute(.success(route)):
            state.matchedRoute = route
            return .none
        case let .matchedRoute(.failure(error)):
            state.matchedRoute = nil
            return .fireAndForget {
                log.warning("Unable to handle deep link.", userInfo: error.logInfo)
            }
        }
    }
}

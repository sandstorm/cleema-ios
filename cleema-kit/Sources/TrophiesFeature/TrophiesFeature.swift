//
//  Created by Kumpels and Friends on 09.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Logging
import Models
import TrophyClient

public struct Trophies: ReducerProtocol {
    public struct State: Equatable {
        public var trophies: IdentifiedArrayOf<Trophy> = []
        public var selection: Identified<Trophy.ID, Trophy>?
        public var isLoading = false

        public init(
            trophies: IdentifiedArrayOf<Trophy> = [],
            selection: Identified<Trophy.ID, Trophy>? = nil,
            isLoading: Bool = false
        ) {
            self.trophies = trophies
            self.selection = selection
            self.isLoading = isLoading
        }
    }

    public enum Action: Equatable {
        case load
        case loadResponse(TaskResult<[Trophy]>)
        case setNavigation(selection: Trophy.ID?)
        case dismissSheet
    }

    @Dependency(\.trophyClient.loadTrophies) var loadTrophies
    @Dependency(\.log) var log

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .load:
            state.isLoading = true
            return .task {
                await .loadResponse(
                    TaskResult {
                        try await loadTrophies()
                    }
                )
            }
            .animation(.default)
        case let .loadResponse(.success(trophies)):
            state.isLoading = false
            state.trophies = .init(uniqueElements: trophies)
            return .none
        case let .loadResponse(.failure(error)):
            state.isLoading = false
            state.trophies = []
            return .fireAndForget {
                log.error("Error loading trophies.", userInfo: error.logInfo)
            }
        case let .setNavigation(selection: .some(id)):
            guard let trophy = state.trophies[id: id] else { return .none }
            state.selection = .init(trophy, id: id)
            return .none
        case .setNavigation(selection: .none):
            state.selection = nil
            return .none
        case .dismissSheet:
            state.selection = nil
            return .none
        }
    }
}

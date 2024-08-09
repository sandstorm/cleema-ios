//
//  Created by Kumpels and Friends on 14.10.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Styling
import SwiftUI

public struct Suggestions: ReducerProtocol {
    public struct State: Equatable {
        public var suggestions: IdentifiedArrayOf<Suggestion.State> = []
        public var tags: [Tag] = []

        public init(suggestions: IdentifiedArrayOf<Suggestion.State> = [], tags: [Tag] = []) {
            self.suggestions = suggestions
            self.tags = tags
        }
    }

    public enum Action: Equatable {
        case suggestion(id: Suggestion.State.ID, action: Suggestion.Action)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            .none
        }
        .forEach(\.suggestions, action: /Action.suggestion(id:action:)) {
            Suggestion()
        }
    }
}

public struct Suggestion: ReducerProtocol {
    public enum State: Equatable, Identifiable {
        case tag(Tag)

        public var id: UUID {
            switch self {
            case let .tag(tag):
                return tag.id.rawValue
            }
        }

        var searchTerm: String {
            switch self {
            case let .tag(tag):
                return tag.value
            }
        }
    }

    public enum Action: Equatable {
        case tapped
    }

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        .none
    }
}

struct SuggestionsView: View {
    let store: StoreOf<Suggestions>

    var body: some View {
        ForEachStore(
            self.store.scope(state: \.suggestions, action: Suggestions.Action.suggestion(id:action:))
        ) { suggestionStore in
            WithViewStore(suggestionStore) { viewStore in
                Button(viewStore.searchTerm) { viewStore.send(.tapped) }
            }
        }
    }
}

//
//  Created by Kumpels and Friends on 23.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation

public struct Search: ReducerProtocol {
    public struct State: Equatable {
        public var term: String
        public var region: Region.ID?
        public var suggestionState: Suggestions.State

        public init(term: String = "", region: Region.ID?, suggestionState: Suggestions.State = .init()) {
            self.term = term
            self.region = region
            self.suggestionState = suggestionState
        }
    }

    public enum Action: Equatable {
        case searchTerm(String, Region.ID?)
        case suggestions(Suggestions.Action)
        case tappedTag(Tag)
        case submit
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.suggestionState, action: /Action.suggestions) {
            Suggestions()
        }
        Reduce { state, action in
            switch action {
            case let .searchTerm(term, region):
                state.term = term
                state.region = region
                state.suggestionState.suggestions = .init(
                    uniqueElements: state.suggestionState.tags
                        .filter { $0.value.lowercased().hasPrefix(term.lowercased()) }
                        .map(Suggestion.State.tag)
                )
                return .none
            case let .suggestions(Suggestions.Action.suggestion(id: id, action: .tapped)):
                guard let suggestion = state.suggestionState.suggestions[id: id] else { return .none }
                state.term = suggestion.searchTerm
                state.suggestionState.suggestions = []
                return .task { .submit }
            case .submit:
                return .none
            case let .tappedTag(tag):
                state.term = tag.value
                state.suggestionState.suggestions = []
                return .init(value: .submit)
            }
        }
    }
}

import Components
import SwiftUI
import SwiftUIBackports

struct SearchView: View {
    let store: StoreOf<Search>

    var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.term.isEmpty {
                Backport.Flow(data: viewStore.suggestionState.tags, spacing: 4) { tag in
                    Button {
                        viewStore.send(.tappedTag(tag))
                    } label: {
                        TagView(tag: tag)
                    }
                }
            } else {
                SuggestionsView(store: store.scope(state: \.suggestionState, action: Search.Action.suggestions))
            }
        }
        .buttonStyle(.plain)
    }
}

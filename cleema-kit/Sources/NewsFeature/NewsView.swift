//
//  Created by Kumpels and Friends on 20.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Models
import Styling
import SwiftUI
import SwiftUINavigation

public struct NewsView: View {
    let store: StoreOf<AllNews>

    @Environment(\.styleGuide) var styleGuide

    public init(store: StoreOf<AllNews>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEachStore(
                        store.scope(state: \.news, action: AllNews.Action.news(id:action:)),
                        content: { itemStore in
                            WithViewStore(itemStore, observe: { $0 }) { itemViewStore in
                                NavigationLink(
                                    destination: IfLetStore(
                                        store.scope(
                                            state: \.selection?.value,
                                            action: AllNews.Action.newsDetail
                                        )
                                    ) {
                                        NewsDetailView(store: $0)
                                    },

                                    tag: itemViewStore.id,
                                    selection: viewStore.binding(
                                        get: \.selection?.id,
                                        send: AllNews.Action.setNavigation(selection:)
                                    )
                                ) {
                                    SingleNewsView(store: itemStore)
                                }
                                .buttonStyle(.listRow)
                                .padding(.horizontal, styleGuide.screenEdgePadding)
                                .tag(itemViewStore.state)
                            }
                        }
                    )
                }
                .padding(.bottom)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewStore.send(.profileButtonTapped)
                    } label: {
                        Image.profileIcon
                    }
                }
            }
            .task {
                await viewStore.send(.load).finish()
            }
            .refreshable {
                await viewStore.send(.load).finish()
            }
//            .searchable(
//                text: viewStore.binding(
//                    get: \.searchState.term,
//                    send: { AllNews.Action.search(.searchTerm($0, viewStore.searchState.region)) }
//                ),
//                prompt: L10n.Search.prompt, suggestions: {
//                    SearchView(store: store.scope(state: \.searchState, action: AllNews.Action.search))
//                }
//            )
            .onSubmit(of: .search) {
                viewStore.send(.search(.submit))
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationTitle(L10n.title)
        }
    }
}

// MARK: - Preview

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewsView(
                store: Store(
                    initialState: .init(searchState: .init(region: Region.leipzig.id)),
                    reducer: AllNews()
                )
            )
            .background(ScreenBackgroundView())
        }
        .cleemaStyle()
    }
}

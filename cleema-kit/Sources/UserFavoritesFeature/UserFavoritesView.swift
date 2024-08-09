//
//  Created by Kumpels and Friends on 15.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import NewsFeature
import ProjectDetailFeature
import Styling
import SwiftUI

extension UserFavorites.State.Item {
    var title: String {
        switch self {
        case let .project(project):
            return project.project.title
        case let .news(news):
            return news.title
        }
    }

    var icon: Image {
        switch self {
        case .project:
            return Styling.projectsIcon
        case .news:
            return Styling.newsIcon
        }
    }
}

public struct UserFavoritesView: View {
    let store: StoreOf<UserFavorites>

    public init(store: StoreOf<UserFavorites>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                Text(L10n.Section.Favorites.label)
                    .font(.montserratBold(style: .title, size: 16))

                ZStack(alignment: .topLeading) {
                    if viewStore.isLoading {
                        ProgressView(L10n.Loading.Progress.label)
                    } else {
                        if viewStore.items.isEmpty {
                            Text(L10n.Favorites.Empty.label)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical)
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(viewStore.items) { item in
                                    Button {
                                        viewStore.send(
                                            UserFavorites.Action.select(item.id)
                                        )
                                    } label: {
                                        HStack(spacing: 12) {
                                            item.icon
                                                .opacity(0.66)
                                            Text(item.title)
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .buttonStyle(.favorites)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .sheet(
                    isPresented: viewStore.binding(
                        get: { $0.selection?.id != nil },
                        send: { id in UserFavorites.Action.select(nil) }
                    )
                ) {
                    NavigationView {
                        IfLetStore(store.scope(state: \.selection?.value)) { selectionStore in
                            SwitchStore(selectionStore) {
                                CaseLet(
                                    /UserFavorites.State.Item.project,
                                    action: UserFavorites.Action.projectDetail
                                ) { projectStore in
                                    ProjectDetailView(store: projectStore, isPresentedInSheet: true)
                                        .navigationBarTitleDisplayMode(.inline)
                                }
                                CaseLet(
                                    /UserFavorites.State.Item.news,
                                    action: UserFavorites.Action.newsDetail
                                ) { newsStore in
                                    NewsDetailView(store: newsStore, isPresentedInSheet: true)
                                        .navigationBarTitleDisplayMode(.inline)
                                }
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(L10n.Detail.Action.Done.label) {
                                    viewStore.send(UserFavorites.Action.select(nil))
                                }
                            }
                        }
                        .backport.presentationDragIndicator(.visible)
                    }
                }
            }
            .task {
                await viewStore.send(.load).finish()
            }
        }
    }
}

struct UserProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserFavoritesView(store: .init(initialState: .init(), reducer: UserFavorites()))
                .navigationTitle("User projects")
        }
    }
}

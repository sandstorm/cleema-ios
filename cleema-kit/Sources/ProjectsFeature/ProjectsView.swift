//
//  Created by Kumpels and Friends on 27.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Models
import ProjectDetailFeature
import SelectRegionFeature
import Styling
import SwiftUI

public struct ProjectsView: View {
    let store: StoreOf<Projects>

    @Environment(\.styleGuide) var styleGuide

    public init(store: StoreOf<Projects>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                SelectRegionView(
                    store: store
                        .scope(state: \.selectRegionState, action: Projects.Action.selectRegion),
                    valuePrefix: L10n.Projects.Filter.Region.valuePrefix
                )
                .tint(.defaultText)
                .padding(.horizontal, styleGuide.screenEdgePadding)
                .padding(.top)

                LazyVStack {
                    ForEachStore(
                        store.scope(
                            state: \.projects,
                            action: Projects.Action.projectRow(id:action:)
                        )
                    ) { rowStore in
                        WithViewStore(rowStore) { rowViewStore in
                            NavigationLink(
                                destination: IfLetStore(
                                    store.scope(
                                        state: \.selection?.value,
                                        action: Projects.Action.projectDetail
                                    )
                                ) {
                                    ProjectDetailView(store: $0)
                                },
                                tag: rowViewStore.id,
                                selection: viewStore.binding(
                                    get: \.selection?.id,
                                    send: Projects.Action.setNavigation(selection:)
                                )
                            ) {
                                ProjectRowView(store: rowStore)
                            }
                            .buttonStyle(.listRow)
                        }
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, styleGuide.screenEdgePadding)
            }
            .onAppear {
                viewStore.send(.task)
            }
            .refreshable {
                viewStore.send(.task)
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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationTitle(L10n.title)
        }
    }
}

// MARK: - Preview

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectsView(
                store: .init(
                    initialState: .init(selectRegionState: .init(selectedRegion: .leipzig)),
                    reducer: Projects()
                )
            )
            .background {
                ScreenBackgroundView()
            }
        }
        .groupBoxStyle(.plain)
    }
}

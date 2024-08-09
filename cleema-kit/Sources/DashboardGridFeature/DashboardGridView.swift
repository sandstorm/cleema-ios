//
//  Created by Kumpels and Friends on 14.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import ProjectDetailFeature
import SwiftUI
import SwiftUINavigation
import UserChallengeFeature

public struct DashboardGridView: View {
    let store: StoreOf<DashboardGrid>

    @Environment(\.styleGuide) var styleGuide

    public init(store: StoreOf<DashboardGrid>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                GridRow(items: viewStore.firstRow, gridSize: styleGuide.threeColumnsWidth) { item in
                    switch item.content {
                    case .social:
                        Button {
                            viewStore.send(.socialItemTapped, animation: .default)
                        } label: {
                            DashboardItemView(content: item)
                        }
                    case .project:
                        NavigationLink(
                            destination:
                            IfLetStore(store.scope(state: \.selection?.value)) { selectionStore in
                                SwitchStore(selectionStore) {
                                    CaseLet(
                                        /DashboardGrid.Selection.project,
                                        action: DashboardGrid.Action.project
                                    ) {
                                        ProjectDetailView(store: $0)
                                    }
                                }
                            },
                            tag: item.id,
                            selection: viewStore.binding(
                                get: \.selection?.id,
                                send: DashboardGrid.Action.setNavigation(selection:)
                            )
                        ) {
                            DashboardItemView(content: item)
                        }
                    default: EmptyView()
                    }
                }

                if !viewStore.secondRow.isEmpty {
                    GridRow(items: viewStore.secondRow, gridSize: styleGuide.threeColumnsWidth) { item in
                        switch item.content {
                        case .project, .social:
                            DashboardItemView(content: item)
                        default: EmptyView()
                        }
                    }
                }
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }
}

struct DashboardGridView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollView {
                DashboardGridView(
                    store: .init(
                        initialState: .init(
                            firstRow: [
                                .init(social: .fake(), isWaveMirrored: false),
                                .init(project: .fake(), isWaveMirrored: true)
                            ],
                            secondRow: [
                                .init(social: .fake(), isWaveMirrored: false),
                                .init(social: .fake(), isWaveMirrored: true),
                                .init(social: .fake(), isWaveMirrored: false),
                                .init(social: .fake(), isWaveMirrored: true),
                                .init(social: .fake(), isWaveMirrored: false),
                                .init(social: .fake(), isWaveMirrored: true),
                                .init(social: .fake(), isWaveMirrored: false)
                            ]
                        ), reducer: DashboardGrid()
                    )
                )
            }
        }
    }
}

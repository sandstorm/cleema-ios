//
//  Created by Kumpels and Friends on 26.10.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import JoinedChallengesFeature
import PartnerChallengesFeature
import SelectRegionFeature
import Styling
import SwiftUI
import SwiftUIBackports

public struct ChallengesView: View {
    let store: StoreOf<Challenges>

    @Environment(\.styleGuide) var styleGuide

    public init(store: StoreOf<Challenges>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    JoinedChallengesView(
                        store: store
                            .scope(state: \.joinedChallengesState, action: Challenges.Action.joinedChallenges),
                        showsEmptyPlaceholder: true
                    )
                    .padding(.bottom)

                    SelectRegionView(
                        store: store
                            .scope(state: \.selectRegionState, action: Challenges.Action.selectRegion),
                        valuePrefix: L10n.Picker.Region.prefix
                    )
                    .tint(.defaultText)
                    .padding(.horizontal, styleGuide.screenEdgePadding)
                    .padding(.bottom)

                    IfLetStore(
                        store
                            .scope(
                                state: \.partnerChallengesState,
                                action: Challenges.Action.partnerChallenges
                            ),
                        then: PartnerChallengesView.init(store:)
                    ).padding(.bottom)
                }
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: { $0.challengeTemplatesState != nil },
                    send: Challenges.Action.dismissSheet
                )
            ) {
                NavigationView {
                    IfLetStore(
                        store
                            .scope(
                                state: \.challengeTemplatesState,
                                action: Challenges.Action.challengeTemplates
                            ),
                        then: ChallengeTemplateListView.init
                    )
                    .navigationTitle(L10n.CreateChallenge.title)
                }
                .backport.presentationDetents([.large])
                .backport.presentationDragIndicator(.visible)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewStore.send(.addChallengeTapped)
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color.accent)
                    }
                }

                ToolbarItem(placement: .automatic) {
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

struct ChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChallengesView(store: .init(
                initialState: .init(
                    selectRegionState: .init(),
                    joinedChallengesState: .init(),
                    partnerChallengesState: nil,
                    userRegion: .leipzig
                ),
                reducer: Challenges()
            ))
            .background {
                ScreenBackgroundView()
            }
        }
        .groupBoxStyle(.plain)
    }
}

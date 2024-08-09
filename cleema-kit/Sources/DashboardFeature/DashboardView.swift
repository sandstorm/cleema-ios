//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import BecomePartner
import BecomeSponsor
import ComposableArchitecture
import DashboardGridFeature
import InfoFeature
import JoinedChallengesFeature
import QuizFeature
import Styling
import SurveysFeature
import SwiftUI

public struct DashboardView: View {
    let store: StoreOf<Dashboard>

    @Environment(\.styleGuide) var styleGuide

    public init(store: StoreOf<Dashboard>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: styleGuide.interItemSpacing) {
                    DashboardGridView(store: store.scope(state: \.gridState, action: Dashboard.Action.grid))

                    QuizFeatureView(store: store.scope(state: \.quizState, action: Dashboard.Action.quiz))

                    if viewStore.surveysState.showsSurveys {
                        SurveysView(store: store.scope(state: \.surveysState, action: Dashboard.Action.surveys))
                    }

                    JoinedChallengesView(
                        store: store
                            .scope(state: \.joinedChallengesState, action: Dashboard.Action.joinedChallengeList),
                        showsTitle: false
                    )
                }
                .padding(.vertical)
                .buttonStyle(.listRow)
            }
            .task {
                viewStore.send(.load)
                viewStore.send(.surveys(.task))

                await viewStore.send(.task).finish()
            }
            // // Sponsorships aren't used anymore in our app
            //.sheet(
            //    isPresented: viewStore.binding(
            //        get: { $0.becomeSponsorState != nil },
            //        send: Dashboard.Action.dismissSheet
            //    )
            //) {
            //    IfLetStore(store.scope(state: \.becomeSponsorState, action: Dashboard.Action.becomeSponsor)) {
            //        BecomeSponsorView(store: $0)
            //    }
            //}
            //
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationTitle(L10n.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(InfoDetail.ID.allCases) { infoID in
                            if (infoID != InfoDetail.ID.sponsorship) {
                                    Button(infoID.title) {
                                        viewStore.send(.infoButtonTapped(infoID))
                                    }
                            }
                        }
                    } label: {
                        Text(verbatim: "\u{2261}")
                            .font(.system(size: 34))
                            .foregroundColor(.accent)
                            .offset(y: -3)
                            .accessibilityLabel(L10n.Info.Menu.axLabel)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Image.cleemaLogo
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewStore.send(.profileButtonTapped)
                    } label: {
                        Image.profileIcon
                    }
                }
            }
            .refreshable {
                viewStore.send(.load)
                viewStore.send(.quiz(.load))
                viewStore.send(.surveys(.task))
            }
        }
    }
}

// MARK: Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView(
                store: .init(
                    initialState: .init(gridState: .init()),
                    reducer: Dashboard()
                        .dependency(\.challengesClient, .preview)
                )
            )
            .background {
                ScreenBackgroundView()
            }
        }
    }
}

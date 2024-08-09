//
//  Created by Kumpels and Friends on 05.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ChallengesClient
import Components
import ComposableArchitecture
import Foundation
import Models
import Styling
import XCTestDynamicOverlay

public struct PartnerChallengeList: ReducerProtocol {
    public struct State: Equatable {
        public init(region: Region, challenges: IdentifiedArrayOf<Challenge> = [], isLoading: Bool = false) {
            self.region = region
            self.challenges = challenges
            self.isLoading = isLoading
        }

        public var region: Region
        public var challenges: IdentifiedArrayOf<Challenge>
        public var isLoading: Bool = false
        public var selection: Identified<Challenge.ID, PartnerChallenge.State>?
    }

    public enum Action: Equatable {
        case task
        case loadResponse(TaskResult<[Challenge]>)
        case setNavigation(Challenge.ID?)
        case partnerChallenge(id: Challenge.ID, action: PartnerChallenge.Action)
        case detail(PartnerChallenge.Action)
        case setRegion(Region)
    }

    @Dependency(\.challengesClient.partnerChallenges) private var partnerChallengesStream

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            enum PartnerLoadID {}
            switch action {
            case .task:
                state.isLoading = true
                return .run { [region = state.region] send in
                    for try await partnerChallenges in partnerChallengesStream(region) {
                        await send(.loadResponse(.success(partnerChallenges)))
                    }
                } catch: { error, send in
                    await send(.loadResponse(.failure(error)))
                }
                .cancellable(id: PartnerLoadID.self, cancelInFlight: true)
            case let .loadResponse(.success(challenges)):
                state.isLoading = false
                // We filter in backend for only partner and collective challenges, so we don't need to do it in frontend as well
                //state.challenges = .init(uniqueElements: challenges.filter(\.isPartner))
                state.challenges = .init(uniqueElements: challenges)
                return .none
            case .loadResponse(.failure):
                // TODO: Handle error???
                state.isLoading = false
                state.challenges = []
                return .none
            case let .setRegion(region):
                state.region = region
                return .task { .task }
            case let .setNavigation(challengeID?):
                guard let challenge = state.challenges[id: challengeID] else {
                    return .none
                }
                state.selection = .init(.init(challenge: challenge), id: challengeID)
                return .none
            case .setNavigation(nil):
                state.selection = nil
                return .none
            case .partnerChallenge:
                return .none
            case .detail:
                return .none
            }
        }
        .ifLet(\.selection, action: /Action.detail) {
            Scope(state: \Identified<Challenge.ID, PartnerChallenge.State>.value, action: /.self) {
                PartnerChallenge()
            }
        }
    }
}

import SwiftUI

public struct PartnerChallengesView: View {
    let store: StoreOf<PartnerChallengeList>

    @Environment(\.styleGuide) var styleGuide

    public init(store: StoreOf<PartnerChallengeList>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                if viewStore.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tint(.white)
                } else if !viewStore.challenges.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(viewStore.challenges) { challenge in
                                NavigationLink(
                                    destination: IfLetStore(
                                        store.scope(
                                            state: \.selection?.value,
                                            action: PartnerChallengeList.Action.detail
                                        ),
                                        then: PartnerChallengeView.init(store:)
                                    ),
                                    tag: challenge.id,
                                    selection: viewStore.binding(
                                        get: \.selection?.id,
                                        send: PartnerChallengeList.Action.setNavigation
                                    )
                                ) {
                                    PartnerChallengeItemView(challenge: challenge)
                                }
                                .buttonStyle(.listRow)
                                .cardShadow()
                            }
                            .frame(width: max(0, styleGuide.singleColumnWidth))
                            .padding(.bottom, styleGuide.interItemSpacing)
                        }
                        .padding(.horizontal, styleGuide.screenEdgePadding)
                        .padding(.bottom, CardShadowModifier.shadowBottomSpacing - styleGuide.interItemSpacing)
                        .buttonStyle(.action)
                    }
                }
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }
}

struct PartnerChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PartnerChallengesView(store: .init(
                initialState: .init(region: .pirna, challenges: []),
                reducer: PartnerChallengeList()
            ))
        }
    }
}

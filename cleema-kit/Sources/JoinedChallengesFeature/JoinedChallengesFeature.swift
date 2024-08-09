//
//  Created by Kumpels and Friends on 23.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models
import UserChallengeFeature

public struct JoinedChallengesList: ReducerProtocol {
    public struct State: Equatable {
        public var challenges: IdentifiedArrayOf<JoinedChallenge>
        public var selection: Identified<JoinedChallenge.ID, UserChallenge.State>? {
            // TODO: Add test
            didSet {
                guard let selection = selection else { return }
                challenges[id: selection.id]? = selection.value.userChallenge
            }
        }

        public init(
            challenges: [JoinedChallenge] = [],
            selection: Identified<JoinedChallenge.ID, UserChallenge.State>? = nil
        ) {
            self.challenges = .init(uniqueElements: challenges)
            self.selection = selection
        }
    }

    public enum Action: Equatable {
        case task
        case userChallengesResponse([JoinedChallenge])
        case setNavigation(selection: JoinedChallenge.ID?)
        case userChallenge(UserChallenge.Action)
        case addChallengeTapped
    }

    @Dependency(\.challengesClient.joinedChallenges) private var joinedChallenges

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for await challenges in joinedChallenges() {
                        await send(.userChallengesResponse(challenges))
                    }
                }
                .animation()
            case let .userChallengesResponse(userChallenges):
                state.challenges = .init(uniqueElements: userChallenges)
                return .none
            case let .setNavigation(selection?):
                guard let challenge = state.challenges[id: selection] else { return .none }
                state.selection = .init(.init(userChallenge: challenge), id: challenge.id)
                return .none
            case let .userChallenge(.leaveChallengeResponse(.success(challenge))):
                state.challenges.remove(id: challenge.id)
                state.selection = nil
                return .none
            case .setNavigation(selection: nil):
                state.selection = nil
                return .none
            case .userChallenge:
                return .none
            case .addChallengeTapped:
                return .none
            }
        }
        .ifLet(\.selection, action: /Action.userChallenge) {
            Scope(state: \Identified.value, action: .self) {
                UserChallenge()
            }
        }
    }
}

import SwiftUI

public struct JoinedChallengesView: View {
    let store: StoreOf<JoinedChallengesList>
    var showsTitle: Bool
    var showsEmptyPlaceholder: Bool

    @Environment(\.styleGuide) var styleGuide

    public init(store: StoreOf<JoinedChallengesList>, showsTitle: Bool = true, showsEmptyPlaceholder: Bool = false) {
        self.store = store
        self.showsTitle = showsTitle
        self.showsEmptyPlaceholder = showsEmptyPlaceholder
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                if !viewStore.challenges.isEmpty {
                    if showsTitle {
                        Text(L10n.title)
                            .font(.montserrat(style: .headline, size: 17))
                            .foregroundColor(.white)
                            .padding(.horizontal, styleGuide.screenEdgePadding)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: styleGuide.interItemSpacing) {
                            ForEach(viewStore.challenges) { userChallenge in
                                NavigationLink(
                                    destination: IfLetStore(
                                        store.scope(
                                            state: \.selection?.value,
                                            action: JoinedChallengesList.Action.userChallenge
                                        ),
                                        then: UserChallengeView.init(store:)
                                    ),
                                    tag: userChallenge.id,
                                    selection: viewStore.binding(
                                        get: \.selection?.id,
                                        send: JoinedChallengesList.Action.setNavigation(selection:)
                                    )
                                ) {
                                    JoinedChallengeItemView(joinedChallenge: userChallenge)
                                }
                                .buttonStyle(.listRow)
                                .frame(width: styleGuide.twoColumnsWidth)
                            }
                        }
                        .padding(.horizontal, styleGuide.screenEdgePadding)
                        .frame(height: styleGuide.twoColumnsWidth)
                    }
                } else if showsEmptyPlaceholder {
                    Button(action: { viewStore.send(.addChallengeTapped) }) {
                        ZStack {
                            Color.clear

                            Text(L10n.Placeholder.emptyChallenges)
                                .font(.montserrat(style: .title, size: 16))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                            Image(systemName: "plus.circle")
                                .font(.system(size: 32))
                                .foregroundColor(.action)
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                        .aspectRatio(1, contentMode: .fit)
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.regularMaterial)
                        }
                    }
                    .padding(.horizontal, styleGuide.screenEdgePadding)
                    .frame(height: styleGuide.twoColumnsWidth)
                }
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }
}

struct JoinedChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JoinedChallengesView(
                store: .init(
                    initialState: .init(),
                    reducer: JoinedChallengesList()
                        .dependency(
                            \.challengesClient.joinedChallenges,
                            {
                                AsyncStream<[JoinedChallenge]> { continuation in
                                    continuation.yield([
                                        .fake(), .fake(), .fake()
                                    ])
                                    continuation.finish()
                                }
                            }
                        )
                )
            )
        }
    }
}

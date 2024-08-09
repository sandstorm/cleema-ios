//
//  Created by Kumpels and Friends on 22.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Models
import SwiftUI

struct InvolvementGoalState: Equatable {
    var currentCount = 0
    var maxCount = 100
    var isLoading = false
    var joined = false
    var engageDisabled = false
}

extension ProjectDetail.State {
    var involvementState: InvolvementGoalState? {
        guard case let .involvement(currentParticipants, maxParticipants, joined) = project.goal else {
            return nil
        }
        return InvolvementGoalState(
            currentCount: currentParticipants,
            maxCount: maxParticipants,
            isLoading: isLoading,
            joined: joined,
            engageDisabled: !project.canEngage
        )
    }
}

struct InvolvementGoalView: View {
    let store: Store<InvolvementGoalState, ProjectDetail.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                PersonsJoinedView(
                    count: viewStore.currentCount,
                    hasJoined: viewStore.joined,
                    totalNeeded: viewStore.maxCount
                )

                Spacer()

                if !viewStore.engageDisabled {
                    let engageButtonLabel: String = {
                        if viewStore.engageDisabled {
                            return L10n.Involvement.Action.disabled
                        } else {
                            return viewStore.joined ? L10n.Involvement.Action.Leave.label : L10n.Involvement.Action.Join
                                .label
                        }
                    }()

                    Button {
                        viewStore.send(.engageButtonTapped)
                    } label: {
                        ZStack {
                            // Following hidden Texts set the width of the button
                            if viewStore.engageDisabled {
                                Text(L10n.Involvement.Action.disabled)
                            } else {
                                Text(L10n.Involvement.Action.Join.label).hidden()
                                Text(L10n.Involvement.Action.Leave.label).hidden()
                            }

                            if viewStore.isLoading {
                                ProgressView()
                                    .controlSize(.small)
                                    .padding(.leading, 2)
                            } else {
                                Text(engageButtonLabel)
                            }
                        }
                    }
                    .buttonStyle(.action)
                    .disabled(viewStore.isLoading || viewStore.engageDisabled)
                }
            }
        }
    }
}

struct InvolvementGoalView_Previews: PreviewProvider {
    static var previews: some View {
        InvolvementGoalView(
            store: .init(
                initialState: .init(currentCount: 3, maxCount: 10),
                reducer: EmptyReducer()
            )
        )
        .padding()
    }
}

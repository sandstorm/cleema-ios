//
//  Created by Kumpels and Friends on 07.09.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models
import ProjectsClient
import Styling
import SwiftUI

public struct ProjectFunding: ReducerProtocol {
    public struct State: Equatable {
        public var id: Project.ID
        public var totalAmount: Int
        public var currentAmount: Int
        public var step: Steps.State = .amount(.custom())

        public init(
            id: Project.ID,
            totalAmount: Int = 0,
            currentAmount: Int = 0,
            step: Steps.State = .amount(.ten)
        ) {
            self.id = id
            self.totalAmount = totalAmount
            self.currentAmount = currentAmount
            self.step = step
        }
    }

    public enum Action: Equatable {
        case steps(Steps.Action)
        case supportResponse(TaskResult<Int>)
    }

    @Dependency(\.projectsClient) var projectsClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.step, action: /Action.steps) {
            Steps()
        }

        Reduce { state, action in
            switch action {
            case .steps(.amount(.supportTapped)):
                guard case let .amount(amountState) = state.step else { return .none }
                state.step = .pending
                return .task { [id = state.id] in
                    await .supportResponse(.init {
                        try await projectsClient.support(id, amountState.amount)
                        return amountState.amount
                    })
                }
            case .steps(.donation(.restartTapped)):
                guard case .donation = state.step else { return .none }
                state.step = .amount(.five)
                return .none
            case .steps:
                return .none
            case let .supportResponse(.success(amount)):
                state.step = .donation(amount: amount)
                return .none
            case .supportResponse(.failure):
                return .none
            }
        }
    }
}

public enum PendingAction: Equatable {}

public struct Steps: ReducerProtocol {
    public enum State: Equatable {
        case amount(Amount.State)
        case pending
        case donation(amount: Int)
    }

    public enum Action: Equatable {
        case amount(Amount.Action)
        case pending(PendingAction)
        case donation(Donation.Action)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(
            state: /State.amount,
            action: /Action.amount
        ) {
            Amount()
        }

        Scope(
            state: /State.donation,
            action: /Action.donation
        ) {
            Donation()
        }
    }
}

// MARK: - View

public struct ProjectFundingView: View {
    let store: StoreOf<ProjectFunding>

    public init(store: StoreOf<ProjectFunding>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 12) {
                if viewStore.currentAmount < viewStore.totalAmount {
                    Text(
                        L10n.Funding.Goal.summary(
                            viewStore.state.totalAmount.formatted(.currency(code: "EUR").precision(.fractionLength(0))),
                            viewStore.state.currentAmount
                                .formatted(.currency(code: "EUR").precision(.fractionLength(0)))
                        )
                    )
                    ProgressView(
                        value: Double(min(viewStore.currentAmount, viewStore.totalAmount)),
                        total: Double(viewStore.totalAmount)
                    )

                    SwitchStore(self.store.scope(state: \.step, action: ProjectFunding.Action.steps)) {initialState in 
                        CaseLet(
                            /Steps.State.amount,
                            action: Steps.Action.amount,
                            then: AmountView.init(store:)
                        )

                        CaseLet(/Steps.State.pending, action: Steps.Action.pending) { _ in
                            VStack {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .frame(maxWidth: .infinity)
                            }
                        }

                        CaseLet(
                            /Steps.State.donation,
                            action: Steps.Action.donation,
                            then: DonationView.init(store:)
                        )
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Text("🎊")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text(
                        L10n.Funding.Goal.reached(
                            viewStore.state.totalAmount.formatted(.currency(code: "EUR").precision(.fractionLength(0)))
                        )
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: Preview

struct ProjectFundingView_Previews: PreviewProvider {
    static var previews: some View {
        let project = [Project].funding.randomElement()!
        return ProjectFundingView(
            store: .init(
                initialState: .init(
                    id: project.id,
                    totalAmount: 1_000,
                    currentAmount: 42,
                    step: .amount(.twenty)
                ),
                reducer: ProjectFunding()
            )
        )
        .padding()
    }
}

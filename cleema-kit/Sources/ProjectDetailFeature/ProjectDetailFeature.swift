//
//  Created by Kumpels and Friends on 20.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Logging
import Models
import ProjectFundingFeature
import ProjectsClient

public struct ProjectDetail: ReducerProtocol {
    public struct State: Equatable {
        public var project: Project
        public var isLoading: Bool
        public var alertState: AlertState<ProjectDetail.Action>?
        public var fundingState: ProjectFunding.State?

        public init(project: Project, isLoading: Bool = false, alertState: AlertState<ProjectDetail.Action>? = nil) {
            self.project = project
            self.isLoading = isLoading
            self.alertState = alertState
            if case let .funding(currentAmount, totalAmount) = project.goal {
                fundingState =
                    .init(.init(
                        id: project.id,
                        totalAmount: totalAmount,
                        currentAmount: currentAmount,
                        step: .amount(.fifteen)
                    ))
            }
        }
    }

    public enum Action: Equatable {
        case engageButtonTapped
        case projectResponse(TaskResult<Project>)
        case leaveConfirmationTapped
        case dismissAlert
        case funding(ProjectFunding.Action)
        case favoriteTapped
    }

    @Dependency(\.projectsClient) var projectsClient
    @Dependency(\.log) var log

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .engageButtonTapped:
                guard
                    state.project.canEngage,
                    case let .involvement(_, _, joined) = state.project.goal
                else { return .none }

                if joined {
                    state.alertState = .leave(title: state.project.title)
                    return .none
                } else {
                    state.isLoading = true
                    return .task { [project = state.project] in
                        await .projectResponse(.init {
                            try await projectsClient.join(project.id)
                        })
                    }
                }
            case let .projectResponse(.success(project)):
                state.project = project
                state.isLoading = false
                return .none
            case let .projectResponse(.failure(error)):
                state.isLoading = false
                return .fireAndForget {
                    log.error("Error loading project response", userInfo: error.logInfo)
                }
            case .leaveConfirmationTapped:
                state.alertState = nil
                state.isLoading = true
                return .task { [project = state.project] in
                    await .projectResponse(.init {
                        try await projectsClient.leave(project.id)
                    })
                }
            case .dismissAlert:
                state.alertState = nil
                return .none
            case let .funding(.supportResponse(.success(amount))):
                guard case let .funding(currentAmount, totalAmount) = state.project.goal else { return .none }
                state.project.goal = .funding(currentAmount: currentAmount + amount, totalAmount: totalAmount)
                state.fundingState?.currentAmount += amount
                return .none
            case .funding:
                return .none
            case .favoriteTapped:
                state.isLoading = true
                return .task { [project = state.project] in
                    await .projectResponse(
                        .init {
                            try await projectsClient.fav(project.id, !project.isFaved)
                        }
                    )
                }
            }
        }
        .ifLet(\.fundingState, action: /ProjectDetail.Action.funding) {
            ProjectFunding()
        }
    }
}

extension ProjectDetail.State: Identifiable {
    public var id: Project.ID { project.id }
}

public extension AlertState where Action == ProjectDetail.Action {
    static func leave(title: String) -> Self {
        .init(
            title: TextState(L10n.Alert.Leave.title(title)),
            buttons: [
                .cancel(TextState(L10n.Alert.Leave.Button.Cancel.label)),
                .destructive(
                    TextState(L10n.Alert.Leave.Button.Leave.label),
                    action: .send(.leaveConfirmationTapped)
                )
            ]
        )
    }
}

//
//  Created by Kumpels and Friends on 25.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Models
import ProjectDetailFeature
import SelectRegionFeature
import SwiftUI

public struct Projects: ReducerProtocol {
    public struct State: Equatable {
        public var projects: IdentifiedArrayOf<ProjectDetail.State> = []
        public var isLoading = false
        public var selection: Identified<Project.ID, ProjectDetail.State>?
        public var selectRegionState: SelectRegion.State

        public init(
            projects: IdentifiedArrayOf<ProjectDetail.State> = [],
            selectRegionState: SelectRegion.State,
            isLoading: Bool = false,
            selection: Identified<Project.ID, ProjectDetail.State>? = nil
        ) {
            self.projects = projects
            self.selectRegionState = selectRegionState
            self.isLoading = isLoading
            self.selection = selection
        }
    }

    public enum Action: Equatable, BindableAction {
        case task
        case loadingResponse([Project])
        case binding(BindingAction<State>)
        case setNavigation(selection: Project.ID?)
        case projectRow(id: Project.ID, action: ProjectDetail.Action)
        case projectDetail(ProjectDetail.Action)
        case profileButtonTapped
        case selectRegion(SelectRegion.Action)
    }

    @Dependency(\.projectsClient.projects) var projectsForRegion

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Scope(state: \.selectRegionState, action: /Action.selectRegion) {
            SelectRegion()
        }

        Reduce { state, action in
            switch action {
            case .task:
                guard let regionID = state.selectRegionState.selectedRegion?.id else { return .none }
                state.isLoading = true
                return .task {
                    try await .loadingResponse(projectsForRegion(regionID))
                }
                .animation(state.projects.isEmpty ? nil : .spring())
            case let .loadingResponse(projects):
                state.isLoading = false
                state.projects = .init(uniqueElements: projects.map { .init(project: $0, isLoading: false) })
                return .none
            case .projectDetail, .projectRow:
                return .none
            case let .setNavigation(selection: .some(projectID)):
                guard let project = state.projects[id: projectID] else { return .none }
                state.selection = Identified(project, id: projectID)
                return .none
            case .setNavigation(selection: .none):
                state.selection = nil
                return .none
            case .profileButtonTapped, .binding:
                return .none
            case .selectRegion(.binding):
                return .task { .task }
            case .selectRegion:
                return .none
            }
        }
        .forEach(\.projects, action: /Action.projectRow) {
            ProjectDetail()
        }
        .ifLet(\.selection, action: /Action.projectDetail) {
            Scope(state: \Identified.value, action: .self) {
                ProjectDetail()
            }
        }
    }
}

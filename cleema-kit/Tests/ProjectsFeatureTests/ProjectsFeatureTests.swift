//
//  Created by Kumpels and Friends on 13.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Fakes
import Models
import ProjectsFeature
import SwiftUI
import XCTest
import XCTestDynamicOverlay

extension Array where Element == Project {
    func toDetailState() -> [ProjectDetail.State] {
        map { .init(project: $0, isLoading: false) }
    }
}

@MainActor
final class ProjectsFeatureTests: XCTestCase {
    func testFlow() async throws {
        let store = TestStore(
            initialState: .init(selectRegionState: .init(selectedRegion: .pirna)),
            reducer: Projects()
        )

        let projects: [Project] = [
            .fake(region: .pirna),
            .fake(region: .leipzig),
            .fake(region: .pirna),
            .fake(region: .dresden)
        ]
        store.dependencies.projectsClient.projects = { regionID in
            projects.filter { $0.region.id == regionID }
        }

        await store.send(.task) {
            $0.isLoading = true
        }

        let expectedProjects = [projects[0], projects[2]]

        await store.receive(.loadingResponse(expectedProjects)) {
            $0.projects = .init(uniqueElements: expectedProjects.toDetailState())
            $0.isLoading = false
        }
    }

    func testFilteringProjects() async throws {
        let pirnaProjects = [Project.fake(region: .pirna), .fake(region: .pirna)]
        let leipzigProjects = [Project.fake(region: .leipzig)]
        let dresdenProjects = [Project.fake(region: .dresden)]

        let projects: [Project] = [
            pirnaProjects[0],
            leipzigProjects[0],
            pirnaProjects[1],
            dresdenProjects[0]
        ]

        let map: [Region.ID: [Project]] = [
            Region.leipzig.id: leipzigProjects,
            Region.dresden.id: dresdenProjects,
            Region.pirna.id: pirnaProjects
        ]

        let store = TestStore(
            initialState: .init(selectRegionState: .init(selectedRegion: .pirna)),
            reducer: Projects()
        )

        store.dependencies.projectsClient.projects = { regionID in
            projects.filter { $0.region.id == regionID }
        }

        await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.loadingResponse(pirnaProjects)) {
            $0.projects = .init(uniqueElements: pirnaProjects.toDetailState())
            $0.isLoading = false
        }

        for region in [Region.dresden, .leipzig, .pirna] {
            await store.send(.selectRegion(.binding(.set(\.$selectedRegion, region)))) {
                $0.selectRegionState.selectedRegion = region
            }

            await store.receive(.task) {
                $0.isLoading = true
            }

            await store.receive(.loadingResponse(map[region.id]!)) {
                $0.projects = .init(uniqueElements: map[region.id]!.toDetailState())
                $0.isLoading = false
            }
        }
    }
}

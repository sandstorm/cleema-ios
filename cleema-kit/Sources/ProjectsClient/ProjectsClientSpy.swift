//
//  Created by Kumpels and Friends on 20.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

public final class ProjectsClientSpy {
    public enum Entry: Equatable {
        case projects
        case join(Project.ID)
        case leave(Project.ID)
        case support(Project.ID, Int)
        case fav(Project.ID, Bool)
    }

    public var joinResult: Result<Project, Error> = .success(
        Project
            .fake(goal: .involvement(currentParticipants: 4, maxParticipants: 10, joined: true))
    )
    public var leftResult: Result<Project, Error> = .success(
        Project
            .fake(goal: .involvement(currentParticipants: 3, maxParticipants: 32, joined: false))
    )
    public var favResult: Result<Project, Error> = .success(
        Project
            .fake(goal: .involvement(currentParticipants: 7, maxParticipants: 9, joined: true))
    )
    public var stubbedProjects: [Project] = []
    public var entries: [Entry] = []

    public init(
        joinedID _: Project.ID? = nil,
        leftID _: Project.ID? = nil,
        joinResult: Result<Project, Error> = .success(
            Project
                .fake(goal: .involvement(currentParticipants: 4, maxParticipants: 10, joined: true))
        ),
        leftResult: Result<Project, Error> = .success(
            Project
                .fake(goal: .involvement(currentParticipants: 3, maxParticipants: 32, joined: false))
        ),
        stubbedProjects: [Project] = [],
        supportedID _: Project.ID? = nil,
        supportedAmount _: Int? = nil
    ) {
        self.joinResult = joinResult
        self.leftResult = leftResult
        self.stubbedProjects = stubbedProjects
    }

    public func reset() {
        entries.removeAll()
    }

    public var client: ProjectsClient {
        .init(
            projects: { regionID in
                self.entries.append(.projects)
                return self.stubbedProjects.filter { $0.region.id == regionID }
            },
            join: {
                self.entries.append(.join($0))
                return try self.joinResult.get()
            },
            leave: {
                self.entries.append(.leave($0))
                return try self.leftResult.get()
            },
            support: {
                self.entries.append(.support($0, $1))
            },
            fav: {
                self.entries.append(.fav($0, $1))
                return try self.favResult.get()
            },
            favedProjectsStream: { fatalError("unimplemented") }
        )
    }
}

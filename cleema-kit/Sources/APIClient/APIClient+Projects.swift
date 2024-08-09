//
//  Created by Kumpels and Friends on 12.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Logging
import Models

public extension APIClient {
    @Sendable
    func projects(for regionID: Region.ID?) async throws -> [Project] {
        let result: [ProjectResponse] = try await decoded(for: .projects(.region(regionID?.rawValue)), with: token)
        return result.compactMap {
            Project(rawValue: $0, log: log, baseURL: baseURL)
        }
    }

    @Sendable
    func join(projectID: Project.ID) async throws -> Project {
        let response: ProjectResponse = try await decoded(
            for: .projects(.project(projectID.rawValue, .join)),
            with: token
        )
        guard let project = Project(rawValue: response, log: log, baseURL: baseURL) else {
            throw InvalidResponse()
        }
        return project
    }

    @Sendable
    func leave(projectID: Project.ID) async throws -> Project {
        let response: ProjectResponse = try await decoded(
            for: .projects(.project(projectID.rawValue, .leave)),
            with: token
        )
        guard let project = Project(rawValue: response, log: log, baseURL: baseURL) else {
            throw InvalidResponse()
        }
        return project
    }

    @Sendable
    func fav(projectID: Project.ID, shouldBeFaved: Bool) async throws -> Project {
        let response: ProjectResponse = try await decoded(
            for: .projects(.project(projectID.rawValue, shouldBeFaved ? .fav : .unfav)),
            with: token
        )
        guard let project = Project(rawValue: response, log: log, baseURL: baseURL) else {
            throw InvalidResponse()
        }
        return project
    }

    @Sendable
    func favedProjects() async throws -> [Project] {
        let result: [ProjectResponse] = try await decoded(for: .projects(.region(nil, true)), with: token)
        return result.compactMap { Project(rawValue: $0, log: log, baseURL: baseURL) }
    }
}

extension Project {
    init?(rawValue: ProjectResponse, log: Logging? = nil, baseURL: URL) {
        guard let partner = rawValue.partner else {
            log?.debug("nil partner in ProjectResponse", userInfo: ["responseID": rawValue.uuid])
            return nil
        }
        guard let goal = Project.Goal(rawValue, log: log) else {
            return nil
        }
        self.init(
            id: .init(rawValue: rawValue.uuid),
            title: rawValue.title,
            summary: rawValue.summary,
            description: rawValue.description,
            image: .init(rawValue: rawValue.image, baseURL: baseURL),
            teaserImage: .init(rawValue: rawValue.teaserImage, baseURL: baseURL),
            startDate: rawValue.startDate,
            partner: .init(rawValue: partner, baseURL: baseURL),
            region: .init(rawValue: rawValue.region),
            location: .init(rawValue: rawValue.location),
            goal: goal,
            isFaved: rawValue.isFaved,
            phase: .init(rawValue.phase)
        )
    }
}

extension RemoteImage {
    init?(rawValue: ImageResponse?, baseURL: URL) {
        guard
            let rawValue,
            let url = URL(string: rawValue.url, relativeTo: baseURL)
        else { return nil }
        let scale = rawValue.scale
        self.init(
            url: url,
            width: CGFloat(rawValue.width) / scale,
            height: CGFloat(rawValue.height) / scale,
            scale: scale
        )
    }
}

extension Location {
    init?(rawValue: LocationResponse?) {
        guard let rawValue else { return nil }
        guard
            (-90.0 ... 90.0).contains(rawValue.coordinates.latitude),
            (-180.0 ... 180.0).contains(rawValue.coordinates.longitude)
        else { return nil }
        self.init(
            title: rawValue.title,
            coordinate: .init(latitude: rawValue.coordinates.latitude, longitude: rawValue.coordinates.longitude)
        )
    }
}

extension Project.Goal {
    init?(_ response: ProjectResponse, log: Logging? = nil) {
        switch response.goalType {
        case .involvement:
            guard let involvement = response.goalInvolvement else {
                log?.debug("nil goalInvolvement in ProjectResponse", userInfo: ["responseID": response.uuid])
                return nil
            }
            self = .involvement(
                currentParticipants: involvement.currentParticipants,
                maxParticipants: involvement.maxParticipants,
                joined: response.joined
            )
        case .funding:
            guard let funding = response.goalFunding else {
                log?.debug("nil goalFunding in ProjectResponse", userInfo: ["responseID": response.uuid])
                return nil
            }
            self = .funding(currentAmount: Int(funding.currentAmount), totalAmount: Int(funding.totalAmount))
        case .information:
            self = .information
        }
    }
}

extension Project.Phase {
    init(_ phase: ProjectResponse.Phase) {
        switch phase {
        case .pre:
            self = .pre
        case .running:
            self = .within
        case .post:
            self = .post
        case .cancelled:
            self = .cancelled
        }
    }
}

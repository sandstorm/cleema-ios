//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import SwiftUI
import Tagged

public struct Project: Identifiable, Equatable {
    public typealias ID = Tagged<Project, UUID>

    public enum Goal: Equatable {
        case involvement(currentParticipants: Int, maxParticipants: Int, joined: Bool)
        case funding(currentAmount: Int, totalAmount: Int)
        case information
    }

    public enum Phase: Equatable, CaseIterable {
        case pre
        case within
        case post
        case cancelled
    }

    public var id: ID = .init(rawValue: .init())
    public var title: String
    public var summary: String
    public var description: String
    public var image: RemoteImage?
    public var teaserImage: RemoteImage?
    public var startDate: Date
    public var partner: Partner
    public var region: Region
    public var location: Location?
    public var goal: Goal
    public var isFaved: Bool
    public var phase: Phase

    public init(
        id: Project.ID = .init(rawValue: .init()),
        title: String,
        summary: String,
        description: String,
        image: RemoteImage? = nil,
        teaserImage: RemoteImage? = nil,
        startDate: Date,
        partner: Partner,
        region: Region,
        location: Location?,
        goal: Goal = .involvement(currentParticipants: 0, maxParticipants: 1, joined: false),
        isFaved: Bool = false,
        phase: Phase
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.description = description
        self.image = image
        self.teaserImage = teaserImage
        self.startDate = startDate
        self.partner = partner
        self.region = region
        self.location = location
        self.goal = goal
        self.isFaved = isFaved
        self.phase = phase
    }
}

public extension Project {
    var isJoined: Bool {
        guard case let .involvement(_, _, isJoined) = goal else { return false }
        return isJoined
    }
}

extension Project.Phase: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pre:
            return L10n.Project.Phase.Pre.title
        case .within:
            return L10n.Project.Phase.Within.title
        case .post:
            return L10n.Project.Phase.Post.title
        case .cancelled:
            return L10n.Project.Phase.Cancelled.title
        }
    }
}

public extension Project {
    var canEngage: Bool {
        switch (phase, goal) {
        case (.pre, let .involvement(currentParticipants, maxParticipants, false)):
            return currentParticipants < maxParticipants
        case (.pre, .involvement(_, _, true)):
            return true
        case (_, .involvement(_, _, _)):
            return false
        case (_, .funding):
            return false
        case (_, .information):
            return false
        }
    }
}

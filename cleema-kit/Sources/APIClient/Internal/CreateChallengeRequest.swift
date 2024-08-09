//
//  Created by Kumpels and Friends on 23.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

struct CreateChallengeRequest: Codable {
    var title: String
    var teaserText: String
    var description: String
    var startDate: Date
    var endDate: Date
    var kind: Kind
    var isPublic: Bool
    var goalType: GoalType
    var interval: Interval
    var goalSteps: Steps?
    var goalMeasurement: GoalMeasurement?
    var region: RegionRequest
    var participants: [UUID]
    var image: IDRequest?
}

extension CreateChallengeRequest {
    init?(challenge: Challenge, participants: Set<SocialUser.ID>) {
        guard let regionID = challenge.region?.id else { return nil }
        self.init(
            title: challenge.title,
            teaserText: challenge.teaserText,
            description: challenge.description,
            startDate: challenge.startDate,
            endDate: challenge.endDate,
            kind: .init(from: challenge.kind),
            isPublic: challenge.isPublic,
            goalType: .init(from: challenge.type),
            interval: .init(from: challenge.interval),
            goalSteps: .init(from: challenge.type),
            goalMeasurement: .init(from: challenge.type),
            region: .init(uuid: regionID.rawValue),
            participants: participants.map(\.rawValue),
            image: challenge.image.map { IDRequest(uuid: $0.id.rawValue) }
        )
    }
}

extension GoalType {
    init(from type: Challenge.GoalType) {
        switch type {
        case .steps:
            self = .steps
        case .measurement:
            self = .measurement
        }
    }
}

extension GoalMeasurement {
    init?(from type: Challenge.GoalType) {
        switch type {
        case .steps:
            return nil
        case let .measurement(value, unit):
            self.init(value: value, unit: .init(from: unit))
        }
    }
}

extension Steps {
    init?(from type: Challenge.GoalType) {
        switch type {
        case let .steps(count):
            self = .init(count: count)
        case .measurement:
            return nil
        }
    }
}

extension GoalMeasurement.Unit {
    init(from unit: Models.Unit) {
        switch unit {
        case .kilograms: self = .kg
        case .kilometers: self = .km
        }
    }
}

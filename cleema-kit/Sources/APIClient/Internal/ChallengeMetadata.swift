//
//  Created by Kumpels and Friends on 18.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct Answer: Codable {
    enum Status: String, Codable {
        case succeeded
        case failed
    }

    var answer: Status
    var dayIndex: Int
}

enum Kind: String, Codable {
    case user
    case partner
    case group
    case collective
}

enum Interval: String, Codable {
    case daily
    case weekly
}

enum GoalType: String, Codable {
    case steps
    case measurement
}

struct Steps: Codable {
    var count: UInt
}

struct GoalMeasurement: Codable {
    enum Unit: String, Codable {
        case kg
        case km
    }

    var value: UInt
    var unit: Unit
}

extension Kind {
    init(from kind: Challenge.Kind) {
        switch kind {
        case .user:
            self = .user
        case .partner:
            self = .partner
        case .group:
            self = .group
        case .collective:
            self = .collective
        }
    }
}

extension Interval {
    init(from interval: Challenge.Interval) {
        switch interval {
        case .daily:
            self = .daily
        case .weekly:
            self = .weekly
        }
    }
}

extension Answer.Status {
    init(rawValue: JoinedChallenge.Answer) {
        switch rawValue {
        case .failed:
            self = .failed
        case .succeeded:
            self = .succeeded
        }
    }
}

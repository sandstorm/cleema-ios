//
//  Created by Kumpels and Friends on 23.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public enum Unit: Int, Identifiable, CaseIterable {
    case kilometers
    case kilograms

    public var id: Self { self }

    public var title: String {
        switch self {
        case .kilometers:
            return "km"
        case .kilograms:
            return "kg"
        }
    }
}

public struct Challenge: Identifiable {
    public typealias ID = Tagged<Challenge, UUID>
    public enum GoalType: Hashable {
        case steps(UInt)
        case measurement(UInt, Unit)

        public var count: UInt {
            switch self {
            case let .steps(count), let .measurement(count, _): return count
            }
        }

        public var unit: Unit? {
            switch self {
            case .steps: return nil
            case let .measurement(_, unit): return unit
            }
        }
    }

    public enum Interval: String, Identifiable, CaseIterable {
        case daily
        case weekly

        public var id: Self {
            self
        }
    }

    public enum Kind: Equatable {
        case user
        case partner(Partner)
        case group([UserProgress])
        case collective(Partner)
    }

    public var id: ID
    public var title: String
    public var teaserText: String
    public var description: String
    public var type: GoalType
    public var interval: Interval
    public var startDate: Date
    public var endDate: Date
    public var isPublic: Bool
    public var kind: Kind
    public var region: Region?
    public var isJoined: Bool
    public var sponsor: Partner?
    public var numberOfUsersJoined: Int
    public var image: IdentifiedImage?
    public var collectiveGoalAmount: Int?
    public var collectiveProgress: Int?

    public init(
        id: ID = .init(rawValue: UUID()),
        title: String = "",
        teaserText: String = "",
        description: String = "",
        type: Challenge.GoalType = .steps(1),
        interval: Challenge.Interval = .daily,
        startDate: Date = .now,
        endDate: Date = .now.add(months: 1),
        isPublic: Bool = false,
        kind: Kind = .user,
        region: Region? = nil,
        isJoined: Bool = false,
        sponsor: Partner? = nil,
        numberOfUsersJoined: Int = 0,
        image: IdentifiedImage? = nil,
        collectiveGoalAmount: Int? = nil,
        collectiveProgress: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.teaserText = teaserText
        self.description = description
        self.type = type
        self.interval = interval
        self.isPublic = isPublic
        self.startDate = min(startDate, endDate).startOfDay
        self.endDate = max(startDate, endDate).endOfDay
        self.kind = kind
        self.region = region
        self.isJoined = isJoined
        self.sponsor = sponsor
        self.numberOfUsersJoined = numberOfUsersJoined
        self.image = image
        self.collectiveGoalAmount = collectiveGoalAmount
        self.collectiveProgress = collectiveProgress
    }
}

public enum Duration: Equatable {
    case days(Int)
    case weeks(Int)
}

public extension Duration {
    /// Returns the duration. For the `days` case the number of days, for the `weeks` case the number of weeks
    var unitValueCount: Int {
        switch self {
        case let .days(count), let .weeks(count):
            return count
        }
    }

    var dayCount: Int {
        switch self {
        case let .days(count):
            return count
        case let .weeks(count):
            return count * 7
        }
    }

    var unit: String {
        switch self {
        case .days:
            return L10n.Unit.days
        case .weeks:
            return L10n.Unit.weeks
        }
    }
}

public extension Challenge {
    var duration: Duration {
        switch interval {
        case .daily:
            let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day!
            return .days(days + 1)
        case .weekly:
            let components = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: endDate)
            return .weeks(components.weekOfYear! + 1)
        }
    }

    func ordinal(for date: Date) -> Int? {
        guard (startDate ... endDate).contains(date) else { return nil }
        switch duration {
        case .days:
            let days = startDate.numberOfDays(to: date) + 1
            guard days <= duration.unitValueCount else {
                return nil
            }
            return days
        case .weeks:
            let weeks = startDate.numberOfWeeks(to: date) + 1
            guard weeks <= duration.unitValueCount else {
                return nil
            }
            return weeks
        }
    }
}

extension Challenge: Equatable {
    public static func == (lhs: Challenge, rhs: Challenge) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.teaserText == rhs.teaserText &&
            lhs.description == rhs.description &&
            lhs.type == rhs.type &&
            lhs.interval == rhs.interval &&
            Calendar.current.isDate(lhs.startDate, equalTo: rhs.startDate, toGranularity: .second) &&
            Calendar.current.isDate(lhs.endDate, equalTo: rhs.endDate, toGranularity: .second) &&
            lhs.isPublic == rhs.isPublic &&
            lhs.kind == rhs.kind &&
            lhs.region == rhs.region &&
            lhs.isJoined == rhs.isJoined &&
            lhs.numberOfUsersJoined == rhs.numberOfUsersJoined &&
            lhs.image == rhs.image
    }
}

public extension Challenge {
    var isPartner: Bool {
        guard case .partner = kind else { return false }
        return true
    }

    var partner: Partner? {
        guard case let .partner(partner) = kind else { return nil }
        return partner
    }

    var isGroup: Bool {
        guard case .group = kind else { return false }
        return true
    }
}

public extension Challenge.Kind {
    var badgeText: String {
        switch self {
        case .user:
            return "SC"
        case .partner:
            return "PC"
        case .group:
            return "GC"
        case .collective:
            return "CC"
        }
    }
}

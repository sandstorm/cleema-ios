//
//  Created by Kumpels and Friends on 20.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Fakes
import Foundation

public extension Challenge {
    static func fake(
        id: ID = .init(rawValue: .init()),
        title: String = [.word(), .word(), .word()].joined(separator: " "),
        teaserText: String = .sentence(),
        description: String = [.sentence(), .sentence(), .sentence()].joined(separator: ". "),
        type: GoalType? = .steps(42),
        interval: Interval = .allCases.randomElement()!,
        startDate: Date = .now,
        endDate: Date = Calendar.current.date(byAdding: .day, value: (1 ... 31).randomElement()!, to: .now)!,
        isPublic: Bool = .random(),
        kind: Kind = Bool.random() ? .user : .partner(.fake()),
        region: Region? = [.dresden, .leipzig, .pirna].randomElement()!,
        isJoined: Bool = .random(),
        numberOfJoinedUsers: Int = Int.random(in: 0 ... 100),
        image: IdentifiedImage? = IdentifiedImage(id: .init(), image: RemoteImage.fake(width: 1_200, height: 900))
    ) -> Self {
        .init(
            id: id,
            title: title,
            teaserText: teaserText,
            description: description,
            type: type ?? .fake(),
            interval: interval,
            startDate: startDate,
            endDate: endDate,
            isPublic: isPublic,
            kind: kind,
            region: region,
            isJoined: isJoined,
            numberOfUsersJoined: numberOfJoinedUsers,
            image: image
        )
    }
}

extension Challenge.GoalType {
    static func fake(
        count: UInt = UInt.random(in: 1 ... 10),
        unit: Models.Unit? = Bool.random() ? nil : .kilograms
    ) -> Self {
        .init(count: count, unit: unit)
    }

    init(count: UInt, unit: Models.Unit?) {
        if let unit = unit {
            self = .measurement(count, unit)
        } else {
            self = .steps(count)
        }
    }
}

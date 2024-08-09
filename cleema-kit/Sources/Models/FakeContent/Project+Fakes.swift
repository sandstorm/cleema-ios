//
//  Created by Kumpels and Friends on 20.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Fakes
import Foundation

public extension Project {
    static func fake(
        id: ID = .init(rawValue: .init()),
        title: String = .word(),
        summary: String = .sentences.prefix(Int.random(in: 2 ... 3)).joined(separator: ". "),
        description: String = .sentences.prefix(Int.random(in: 5 ... 7)).joined(separator: ".\n\n"),
        image: RemoteImage? = .fake(),
        teaserImage: RemoteImage? = .fake(),
        startDate: Date = .now,
        partner: Partner = .fake(),
        region: Region = .fake(),
        location: Location = .fake(),
        goal: Project.Goal = .fake(),
        isFaved: Bool = .random(),
        phase: Phase = .allCases.randomElement()!
    ) -> Self {
        .init(
            id: id,
            title: title,
            summary: summary,
            description: description,
            image: image,
            teaserImage: teaserImage,
            startDate: startDate,
            partner: partner,
            region: region,
            location: location,
            goal: goal,
            isFaved: isFaved,
            phase: phase
        )
    }
}

public extension Project.Goal {
    static func fake() -> Self {
        let values: [Project.Goal] = [
            .involvement(
                currentParticipants: Int.random(in: 1 ... 10),
                maxParticipants: Int.random(in: 10 ... 20),
                joined: Bool.random()
            ),
            .funding(
                currentAmount: Int.random(in: 1 ... 100),
                totalAmount: Int.random(in: 101 ... 1_000_000)
            ),
            .information
        ]
        return values.randomElement()!
    }
}

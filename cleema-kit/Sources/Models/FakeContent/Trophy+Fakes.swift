//
//  Created by Kumpels and Friends on 30.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Fakes
import Foundation

public extension Trophy {
    static func fake(
        id: ID = .init(rawValue: .init()),
        date: Date = .init(timeIntervalSinceReferenceDate: TimeInterval.random(in: 1 ... 1_000_000)),
        title: String = .word(),
        image: RemoteImage = .fake(width: 104, height: 104)
    ) -> Self {
        .init(
            id: id,
            date: date,
            title: title,
            image: image
        )
    }
}

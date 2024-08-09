//
//  Created by Kumpels and Friends on 25.07.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Fakes
import Foundation

public extension SocialItem {
    static func fake(
        title: String = .word(),
        text: String = .sentence(),
        badgeNumber: Int = Int.random(in: 0 ... 3)
    ) -> Self {
        .init(
            title: title,
            text: text,
            badgeNumber: badgeNumber
        )
    }
}

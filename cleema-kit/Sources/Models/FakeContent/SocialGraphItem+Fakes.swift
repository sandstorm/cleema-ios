//
//  Created by Kumpels and Friends on 23.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

public extension SocialGraphItem {
    static func fake(
        id: ID = .init(rawValue: .init()),
        user: SocialUser = .fake()
    ) -> Self {
        .init(
            id: id,
            user: user
        )
    }
}

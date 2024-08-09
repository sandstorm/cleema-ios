//
//  Created by Kumpels and Friends on 26.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Fakes
import Foundation

public extension SocialUser {
    static func fake(
        id: ID = .init(rawValue: .init()),
        username: String = .word(),
        avatar: RemoteImage? = .fake(width: 50, height: 50)
    ) -> Self {
        .init(
            id: id,
            username: username,
            avatar: avatar
        )
    }
}

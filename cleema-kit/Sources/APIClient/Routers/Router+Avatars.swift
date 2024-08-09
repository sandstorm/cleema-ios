//
//  Created by Kumpels and Friends on 13.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

enum AvatarsRoute {
    case fetchList
}

let avatarsRouter = OneOf {
    Route(.case(AvatarsRoute.fetchList)) {
        Query {
            Field("populate") { "*" }
        }

        Path {
            "user-avatars"
        }
    }
}

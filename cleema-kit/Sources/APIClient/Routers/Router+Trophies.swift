//
//  Created by Kumpels and Friends on 29.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

enum TrophiesRoute {
    case me
    case new
}

let trophiesRouter = OneOf {
    Route(.case(TrophiesRoute.me))

    Route(.case(TrophiesRoute.new)) {
        Path {
            "new"
        }
    }
}

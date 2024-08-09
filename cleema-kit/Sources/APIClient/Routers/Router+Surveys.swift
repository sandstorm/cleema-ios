//
//  Created by Kumpels and Friends on 25.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

enum SurveysRoute {
    case fetch
    case participate(UUID)
    case evaluate(UUID)
}

let surveysRouter = OneOf {
    Route(.case(SurveysRoute.fetch))

    Route(.case(SurveysRoute.participate)) {
        Method.patch
        Path {
            UUID.parser()
            "participate"
        }
    }

    Route(.case(SurveysRoute.evaluate)) {
        Method.patch
        Path {
            UUID.parser()
            "evaluate"
        }
    }
}

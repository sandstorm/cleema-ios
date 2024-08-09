//
//  Created by Kumpels and Friends on 25.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

enum RegionsRoute {
    case search(UUID? = nil)
}

let regionsRouter = OneOf {
    Route(.case(RegionsRoute.search)) {
        Path { "regions" }

        Query {
            Field("populate") { "tags" }
            Optionally { Field("filters[uuid][$eq]", default: nil) { UUID.parser() } }
        }
    }
}

//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

enum MarketplaceRoute {
    case offers(UUID? = nil)
    case redeem(UUID)
}

let marketplaceRouter = OneOf {
    Route(.case(MarketplaceRoute.offers)) {
        Query {
            Field("populate") { "*" }
            Optionally { Field("filters[$or][0][region][uuid][$eq]", default: nil) { UUID.parser() } }
            Field("filters[$or][1][isRegional][$eq]") { "false" }
        }
    }

    Route(.case(MarketplaceRoute.redeem)) {
        Method.patch

        Path {
            UUID.parser()
            "redeem"
        }
    }
}

//
//  Created by Kumpels and Friends on 19.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

enum SponsorshipRoute {
    case addMembership(APIRequest<AddSponsorMembershipRequest>)
}

let sponsorshipRouter = OneOf {
    Route(.case(SponsorshipRoute.addMembership)) {
        Method.post
        Path { "support-membership" }
        Headers { Field("Content-Type") { "application/json" } }
        Body(.json(APIRequest<AddSponsorMembershipRequest>.self))
    }
}

//
//  Created by Kumpels and Friends on 23.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct FollowsResponse: Codable {
    var followers: Int
    var followRequests: Int
    var following: Int
    var followingPending: Int
}

//
//  Created by Kumpels and Friends on 16.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

struct UserBox: Codable {
    var user: UserResponse
}

struct UserResponse: Codable {
    var uuid: UUID
    var username: String
    var email: String
    var createdAt: Date
    var referralCode: String
    var acceptsSurveys: Bool
    var region: RegionResponse?
    var follows: FollowsResponse?
    var avatar: IdentifiedImageResponse
    var isSupporter: Bool?
}

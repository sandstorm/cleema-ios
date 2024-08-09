//
//  Created by Kumpels and Friends on 13.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

struct SocialGraphResponse: Codable {
    var followers: [SocialGraphItemResponse]
    var following: [SocialGraphItemResponse]
}

struct SocialGraphItemResponse: Codable {
    var uuid: UUID
    var isRequest: Bool
    var user: SocialUserResponse
}

struct SocialUserResponse: Codable {
    var uuid: UUID
    var username: String
    var avatar: IdentifiedImageResponse?
}

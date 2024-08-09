//
//  Created by Kumpels and Friends on 23.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

struct AuthUserResponse: Codable {
    var uuid: UUID
    var username: String
}

struct AuthResponse: Codable {
    var jwt: String?
    var user: AuthUserResponse
}

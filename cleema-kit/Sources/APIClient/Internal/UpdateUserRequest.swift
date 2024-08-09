//
//  Created by Kumpels and Friends on 13.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct UpdateUserRequest: Codable {
    var username: String?
    var password: String?
    var passwordRepeat: String?
    var email: String?
    var acceptsSurveys: Bool?
    var region: IDRequest?
    var avatar: IDRequest?
}

//
//  Created by Kumpels and Friends on 25.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

public struct Credentials: Equatable, Codable {
    public var username: String
    public var password: String
    public var email: String

    public init(username: String = "", password: String = "", email: String) {
        self.username = username
        self.password = password
        self.email = email
    }
}

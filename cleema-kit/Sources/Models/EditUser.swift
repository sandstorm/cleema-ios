//
//  Created by Kumpels and Friends on 14.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

public struct EditUser: Equatable {
    public var username: String?
    public var password: String?
    public var email: String?
    public var acceptsSurveys: Bool?
    public var region: Region?
    public var avatar: IdentifiedImage?

    public init(
        username: String? = nil,
        password: String? = nil,
        email: String? = nil,
        acceptsSurveys: Bool? = nil,
        region: Region? = nil,
        avatar: IdentifiedImage? = nil
    ) {
        self.username = username
        self.password = password
        self.email = email
        self.acceptsSurveys = acceptsSurveys
        self.region = region
        self.avatar = avatar
    }
}

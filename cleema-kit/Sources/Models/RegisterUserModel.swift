//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

public struct RegisterUserModel: Equatable {
    public var username: String
    public var password: String
    public var email: String
    public var acceptsSurveys: Bool
    public var region: Region
    public var avatar: IdentifiedImage?
    public var clientID: UUID?
    public var referralCode: String?

    public init(
        username: String,
        password: String,
        email: String,
        acceptsSurveys: Bool,
        region: Region,
        avatar: IdentifiedImage? = nil,
        clientID: UUID? = nil,
        referralCode: String? = nil
    ) {
        self.username = username
        self.password = password
        self.email = email
        self.acceptsSurveys = acceptsSurveys
        self.region = region
        self.avatar = avatar
        self.clientID = clientID
        self.referralCode = referralCode
    }
}

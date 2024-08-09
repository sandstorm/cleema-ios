//
//  Created by Kumpels and Friends on 30.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public struct SocialGraph: Equatable {
    public var followers: [SocialGraphItem]
    public var following: [SocialGraphItem]

    public init(followers: [SocialGraphItem], following: [SocialGraphItem]) {
        self.followers = followers
        self.following = following
    }
}

public struct SocialGraphItem: Hashable, Identifiable {
    public typealias ID = Tagged<SocialGraphItem, UUID>

    public var id: ID
    public var user: SocialUser

    public init(id: Tagged<SocialGraphItem, UUID>, user: SocialUser) {
        self.id = id
        self.user = user
    }
}

public struct SocialUser: Hashable, Identifiable {
    public var id: User.ID
    public var username: String
    public var avatar: RemoteImage?

    public init(id: Tagged<User, UUID>, username: String, avatar: RemoteImage? = nil) {
        self.id = id
        self.username = username
        self.avatar = avatar
    }
}

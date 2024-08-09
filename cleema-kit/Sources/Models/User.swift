//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public struct User: Equatable, Identifiable, Codable {
    public typealias ID = Tagged<User, UUID>
    public enum Kind: Equatable, Codable {
        case local
        case remote(password: String, email: String)
    }

    public var id: ID
    public var name: String
    public var region: Region
    public var joinDate: Date
    public var kind: Kind = .local
    public var followerCount: Int
    public var followingCount: Int
    public var acceptsSurveys: Bool
    public var referralCode: String
    public var avatar: IdentifiedImage?
    public var isSupporter: Bool

    public init(
        id: ID = .init(rawValue: .init()),
        name: String,
        region: Region,
        joinDate: Date,
        kind: Kind = .local,
        followerCount: Int = 0,
        followingCount: Int = 0,
        acceptsSurveys: Bool = false,
        referralCode: String,
        avatar: IdentifiedImage? = nil,
        isSupporter: Bool = false
    ) {
        self.id = id
        self.name = name
        self.region = region
        self.joinDate = joinDate
        self.kind = kind
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.acceptsSurveys = acceptsSurveys
        self.referralCode = referralCode
        self.avatar = avatar
        self.isSupporter = isSupporter
    }
}

public extension User {
    var isRemote: Bool {
        switch kind {
        case .local: return false
        case .remote: return true
        }
    }

    @available(*, deprecated, message: "Use optional value of User instead")
    static let empty: Self = .init(
        id: .init(rawValue: .init(uuidString: "00000000-0000-0000-0000-000000000000")!),
        name: "",
        region: .leipzig,
        joinDate: .distantPast,
        referralCode: "00000000-0000-0000-0000",
        avatar: nil
    )

    static let emptyRemote: Self = .init(
        id: .init(rawValue: .init(uuidString: "00000000-0000-0000-0000-000000000000")!),
        name: "",
        region: .leipzig,
        joinDate: .distantPast,
        kind: .remote(password: "", email: ""),
        referralCode: "00000000-0000-0000-0000",
        avatar: nil
    )
}

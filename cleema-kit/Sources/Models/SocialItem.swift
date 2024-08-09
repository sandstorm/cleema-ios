//
//  Created by Kumpels and Friends on 21.07.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public struct SocialItem: Equatable, Identifiable {
    public typealias ID = Tagged<SocialItem, UUID>

    public var id: ID = .init(rawValue: .init())
    public var title: String
    public var text: String
    public var badgeNumber: Int

    public init(id: ID = .init(rawValue: .init()), title: String, text: String, badgeNumber: Int) {
        self.id = id
        self.title = title
        self.text = text
        self.badgeNumber = badgeNumber
    }
}

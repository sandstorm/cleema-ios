//
//  Created by Kumpels and Friends on 25.07.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public struct Tag: Identifiable, Hashable, Codable {
    public typealias ID = Tagged<Tag, UUID>

    public var id: ID
    public var value: String

    public init(id: ID, value: String) {
        self.id = id
        self.value = value
    }
}

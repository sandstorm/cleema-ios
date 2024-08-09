//
//  Created by Kumpels and Friends on 10.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

public extension Region {
    static func fake(
        id: ID = .init(rawValue: .init()),
        name: String = "Pirna"
    ) -> Self {
        .init(
            id: id,
            name: name
        )
    }
}

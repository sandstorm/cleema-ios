//
//  Created by Kumpels and Friends on 29.07.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Fakes
import Foundation
import Tagged

public extension Tag {
    static func fake(
        id: ID = .init(rawValue: .init()),
        value: String = .word()
    ) -> Self {
        .init(
            id: id,
            value: value
        )
    }
}

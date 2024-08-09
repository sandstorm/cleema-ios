//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Fakes
import Foundation

public extension Survey {
    static func fake(
        id: ID = .init(.init()),
        title: String = .words[0 ..< 2].joined(separator: " "),
        description: String = .sentence(),
        state: State = .participation(URL(string: "https://cleema.app")!)
    ) -> Self {
        .init(
            id: id,
            title: title,
            description: description,
            state: state
        )
    }
}

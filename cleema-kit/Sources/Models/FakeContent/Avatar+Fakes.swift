//
//  Created by Kumpels and Friends on 13.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

public extension IdentifiedImage {
    static func fake(
        id: ID = .init(.init()),
        image: RemoteImage = .fake()
    ) -> Self {
        .init(
            id: id,
            image: image
        )
    }
}

//
//  Created by Kumpels and Friends on 29.07.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import CoreLocation
import Foundation

public extension Location {
    static func fake(
        id: ID = .init(rawValue: .init()),
        title: String = "Irgendwo in Dresden",
        coordinate: CLLocationCoordinate2D = .init(
            latitude: 51.0581646966131 + .random(in: 0.0001 ... 0.0009),
            longitude: 13.74131897017187 + .random(in: 0.0001 ... 0.0009)
        )
    ) -> Self {
        .init(
            id: id,
            title: title,
            coordinate: coordinate
        )
    }
}

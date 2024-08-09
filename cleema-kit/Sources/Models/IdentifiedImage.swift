//
//  Created by Kumpels and Friends on 13.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public struct IdentifiedImage: Equatable, Identifiable, Codable {
    public typealias ID = Tagged<IdentifiedImage, UUID>

    public var id: ID
    public var image: RemoteImage

    public init(id: ID, image: RemoteImage) {
        self.id = id
        self.image = image
    }
}

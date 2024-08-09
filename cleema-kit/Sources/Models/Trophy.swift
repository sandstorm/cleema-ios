//
//  Created by Kumpels and Friends on 30.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public struct Trophy: Equatable, Identifiable {
    public typealias ID = Tagged<Trophy, UUID>

    public var id: ID = .init(.init())
    public var date: Date
    public var title: String
    public var image: RemoteImage

    public init(id: ID = .init(.init()), date: Date, title: String, image: RemoteImage) {
        self.id = id
        self.date = date
        self.title = title
        self.image = image
    }
}

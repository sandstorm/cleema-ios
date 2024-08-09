//
//  Created by Kumpels and Friends on 05.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public struct Partner: Equatable, Identifiable, Codable {
    public typealias ID = Tagged<Partner, UUID>
    public var id: ID
    public var title: String
    public var url: URL
    public var description: String?
    public var logo: RemoteImage?

    public init(id: ID, title: String, url: URL, description: String?, logo: RemoteImage?) {
        self.id = id
        self.title = title
        self.url = url
        self.description = description
        self.logo = logo
    }
}

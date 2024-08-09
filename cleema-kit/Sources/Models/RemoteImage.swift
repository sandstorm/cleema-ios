//
//  Created by Kumpels and Friends on 27.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

public struct RemoteImage: Hashable, Codable {
    public var url: URL
    public var width: CGFloat
    public var height: CGFloat
    public var scale: CGFloat

    public init(url: URL, width: CGFloat, height: CGFloat, scale: CGFloat) {
        self.url = url
        self.width = width
        self.height = height
        self.scale = scale
    }
}

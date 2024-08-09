//
//  Created by Kumpels and Friends on 14.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

public extension RemoteImage {
    static func fake(
        url: URL = URL(string: "https://loremflickr.com")!,
        width: CGFloat = 1_050,
        height: CGFloat = 786,
        scale: CGFloat = 3
    ) -> Self {
        .init(
            url: URL(
                string: url.absoluteString
                    .appending("/\(Int(width * scale))/\(Int(height * scale))?random=\(Int.random(in: 0 ... 10_000))")
            )!,
            width: width,
            height: height,
            scale: scale
        )
    }
}

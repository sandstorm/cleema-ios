//
//  Created by Kumpels and Friends on 17.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct NewsResponse: Codable {
    enum MagazineType: String, Codable {
        case news, tip
    }

    var uuid: UUID
    var title: String
    var description: String
    var teaser: String?
    var date: Date
    var publishedAt: Date
    var tags: [TagResponse]
    var image: ImageResponse?
    var type: MagazineType?
    var isFaved: Bool
}

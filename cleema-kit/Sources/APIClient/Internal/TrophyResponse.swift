//
//  Created by Kumpels and Friends on 30.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

struct TrophyItemResponse: Codable {
    var date: Date
    var notified: Bool
    var trophy: TrophyResponse
}

struct TrophyResponse: Codable {
    var title: String
    var amount: Int
    var uuid: UUID
    var image: ImageResponse
}

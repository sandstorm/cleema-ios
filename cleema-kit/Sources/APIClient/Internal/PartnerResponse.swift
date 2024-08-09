//
//  Created by Kumpels and Friends on 05.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct PartnerResponse: Codable {
    var uuid: UUID
    var title: String
    var url: URL
    var description: String?
    var logo: ImageResponse?
}

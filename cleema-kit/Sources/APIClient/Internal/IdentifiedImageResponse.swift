//
//  Created by Kumpels and Friends on 13.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

struct IdentifiedImageResponse: Codable {
    var uuid: UUID
    var image: ImageResponse
}

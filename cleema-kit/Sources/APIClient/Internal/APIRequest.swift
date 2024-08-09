//
//  Created by Kumpels and Friends on 18.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct APIRequest<Content: Codable>: Codable {
    var data: Content
}

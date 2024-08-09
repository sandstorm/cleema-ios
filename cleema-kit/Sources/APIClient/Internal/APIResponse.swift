//
//  Created by Kumpels and Friends on 17.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct APIResponse<ResponseType: Codable>: Codable {
    var data: ResponseType?
    var meta: Metadata?
    var error: ErrorResponse?
}

struct Metadata: Codable {
    var pagination: Pagination?
}

struct Pagination: Codable {
    var page, pageSize, pageCount, total: Int
}

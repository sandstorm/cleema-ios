//
//  Created by Kumpels and Friends on 18.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

extension JSONEncoder {
    static let plainDate: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.plain)
        return encoder
    }()
}

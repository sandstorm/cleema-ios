//
//  Created by Kumpels and Friends on 18.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct RegionRequest {
    var uuid: UUID
}

extension RegionRequest: Codable {
    enum CodingKeys: CodingKey {
        case uuid
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<RegionRequest.CodingKeys> = try decoder
            .container(keyedBy: RegionRequest.CodingKeys.self)

        uuid = try container.decode(UUID.self, forKey: RegionRequest.CodingKeys.uuid)
    }

    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<RegionRequest.CodingKeys> = encoder
            .container(keyedBy: RegionRequest.CodingKeys.self)

        try container.encode(uuid.uuidString.lowercased(), forKey: RegionRequest.CodingKeys.uuid)
    }
}

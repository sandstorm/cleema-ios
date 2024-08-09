//
//  Created by Kumpels and Friends on 16.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

struct CreateUserRequest: Codable {
    var username: String
    var password: String
    var email: String
    var acceptsSurveys: Bool
    var region: IDRequest
    var avatar: IDRequest?
    var clientID: UUID?
    var ref: String?
}

struct IDRequest {
    var uuid: UUID

    init(uuid: UUID) {
        self.uuid = uuid
    }

    init?(id: UUID?) {
        guard let uuid = id else { return nil }
        self.uuid = uuid
    }
}

extension IDRequest: Codable {
    enum CodingKeys: CodingKey {
        case uuid
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<IDRequest.CodingKeys> = try decoder
            .container(keyedBy: IDRequest.CodingKeys.self)

        uuid = try container.decode(UUID.self, forKey: .uuid)
    }

    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<IDRequest.CodingKeys> = encoder
            .container(keyedBy: IDRequest.CodingKeys.self)

        try container.encode(uuid.uuidString.lowercased(), forKey: .uuid)
    }
}

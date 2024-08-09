//
//  Created by Kumpels and Friends on 09.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct ImageResponse: Codable {
    var url: String
    var name: String
    var ext: String
    var width: Int
    var height: Int
}

extension ImageResponse {
    enum CodingKeys: CodingKey {
        case url
        case name
        case ext
        case width
        case height
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<ImageResponse.CodingKeys> = try decoder
            .container(keyedBy: ImageResponse.CodingKeys.self)

        url = try container.decode(String.self, forKey: ImageResponse.CodingKeys.url)
        name = try container.decode(String.self, forKey: ImageResponse.CodingKeys.name)
        ext = try container.decode(String.self, forKey: ImageResponse.CodingKeys.ext)
        width = try container.decode(Int.self, forKey: ImageResponse.CodingKeys.width)
        height = try container.decode(Int.self, forKey: ImageResponse.CodingKeys.height)
    }

    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<ImageResponse.CodingKeys> = encoder
            .container(keyedBy: ImageResponse.CodingKeys.self)

        try container.encode(url, forKey: ImageResponse.CodingKeys.url)
        try container.encode(name, forKey: ImageResponse.CodingKeys.name)
        try container.encode(ext, forKey: ImageResponse.CodingKeys.ext)
        try container.encode(width, forKey: ImageResponse.CodingKeys.width)
        try container.encode(height, forKey: ImageResponse.CodingKeys.height)
    }
}

extension ImageResponse {
    var scale: Double {
        let filename = name.dropLast(ext.count)
        if filename.hasSuffix("@3x") {
            return 3
        }
        if filename.hasSuffix("@2x") {
            return 2
        }
        return 1
    }
}

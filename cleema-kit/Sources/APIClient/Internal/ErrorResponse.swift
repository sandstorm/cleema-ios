//
//  Created by Kumpels and Friends on 15.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

struct ErrorResponse {
    var status: Int
    var name: String
    var message: String
    var details: ErrorDetails?
}

extension ErrorResponse: Codable {
    enum CodingKeys: CodingKey {
        case status
        case name
        case message
        case details
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<ErrorResponse.CodingKeys> = try decoder
            .container(keyedBy: ErrorResponse.CodingKeys.self)

        status = try container.decode(Int.self, forKey: ErrorResponse.CodingKeys.status)
        name = try container.decode(String.self, forKey: ErrorResponse.CodingKeys.name)
        let serverMessage = try container.decode(String.self, forKey: ErrorResponse.CodingKeys.message)
        message = Bundle.module.localizedString(forKey: serverMessage, value: nil, table: "APIClient")
        details = try container.decodeIfPresent(ErrorDetails.self, forKey: ErrorResponse.CodingKeys.details)
    }

    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<ErrorResponse.CodingKeys> = encoder
            .container(keyedBy: ErrorResponse.CodingKeys.self)

        try container.encode(status, forKey: ErrorResponse.CodingKeys.status)
        try container.encode(name, forKey: ErrorResponse.CodingKeys.name)
        try container.encode(message, forKey: ErrorResponse.CodingKeys.message)
        try container.encodeIfPresent(details, forKey: ErrorResponse.CodingKeys.details)
    }
}

struct ErrorDetails: Codable {
    var reason: String? = nil

    enum CodingKeys: CodingKey {
        case reason
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<ErrorDetails.CodingKeys> = try decoder
            .container(keyedBy: ErrorDetails.CodingKeys.self)

        if let rawReason = try container.decodeIfPresent(String.self, forKey: ErrorDetails.CodingKeys.reason) {
            reason = Bundle.module.localizedString(forKey: rawReason, value: nil, table: "APIClient")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<ErrorDetails.CodingKeys> = encoder
            .container(keyedBy: ErrorDetails.CodingKeys.self)
        try container.encodeIfPresent(reason, forKey: ErrorDetails.CodingKeys.reason)
    }
}

extension ErrorResponse: CustomStringConvertible {
    var description: String { message }
}

extension ErrorResponse: CustomDebugStringConvertible {
    var debugDescription: String {
        var text = "name: \(name), message: \(message), status code: \(status)"
        if let reason = details?.reason {
            text += ", reason: \(reason)"
        }
        return text
    }
}

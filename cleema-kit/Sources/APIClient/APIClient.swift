//
//  Created by Kumpels and Friends on 14.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Logging
import Models
import OrderedCollections
import URLRouting

public struct APIError: LocalizedError {
    public var errorDescription: String? {
        response.description
    }

    public var errorDetails: String? {
        response.details?.reason
    }

    var response: ErrorResponse

    init(from response: ErrorResponse) {
        self.response = response
    }
}

public final class APIClient {
    enum Token {
        case base(String, clientID: UUID? = nil)
        case authenticated(String)

        var value: String {
            switch self {
            case let .base(token, _), let .authenticated(token):
                return token
            }
        }

        var clientID: UUID? {
            switch self {
            case let .base(_, id):
                return id
            case .authenticated:
                return nil
            }
        }
    }

    struct UnauthorizedError: LocalizedError {
        var errorDescription: String? = "Unauthorized"
    }

    struct InvalidRequest: LocalizedError { var errorDescription: String? = "Invalid request" }
    struct InvalidResponse: LocalizedError { var errorDescription: String? = "Invalid response" }

    let log: Logging = .default
    let baseURL: URL
    let baseToken: String
    var authResponse: AuthResponse?

    public let baseURI: String
    public var clientID: UUID?

    public init(baseURL: URL, token: String) {
        self.baseURL = baseURL
        baseURI = baseURL.absoluteString
        baseToken = token
    }

    var token: Token {
        if let userToken = authResponse?.jwt {
            return .authenticated(userToken)
        }
        return .base(baseToken, clientID: clientID)
    }

    public func deauthorize() {
        authResponse = nil
        clientID = nil
    }

    @Sendable
    public func tags() async throws -> [Tag] {
        let result: [TagResponse] = try await decoded(for: .news(.tags), with: token)
        return result.map {
            Tag(id: .init(rawValue: $0.uuid), value: $0.value)
        }
    }

    @Sendable
    public func regions(regionID: Region.ID? = nil) async throws -> [Region] {
        let result: [RegionResponse] = try await decoded(
            for: .regions(.search(regionID?.rawValue)),
            with: token
        )
        return result.map(Region.init(rawValue:))
    }
}

extension JSONDecoder {
    static let isoDate: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601WithFractionalSeconds)
        return decoder
    }()

    static let _plainDate: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.plain)
        return decoder
    }()
}

extension APIClient {
    func decoded<Value: Codable>(
        for route: CleemaRoute,
        with token: Token,
        decoder: JSONDecoder = .isoDate
    ) async throws -> Value {
        let client = URLRoutingClient.authenticated(apiURI: baseURI, token: token)
        let (data, _) = try await client.data(for: route)

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                // Print the JSON object to inspect its structure
                print(jsonObject)
            
            let decodedResponse = try decoder.decode(APIResponse<Value>.self, from: data)
            if let fooError = decodedResponse.error {
                throw APIError(from: fooError)
            }
            guard let value = decodedResponse.data else {
                throw InvalidResponse()
            }
            return value
        } catch {
            print("Error decoding response: \(error)")
            throw error
        }
    }
}

extension URLRoutingClient where Route == CleemaRoute {
    static func authenticated(apiURI: String, token: APIClient.Token) -> Self {
        var headers: OrderedDictionary<String, [String?]> = [
            "authorization": ["bearer \(token.value)"]
        ]
        if let clientID = token.clientID {
            headers["cleema-install-id"] = [clientID.uuidString]
        }
        let authenticatedRouter = apiRouter
            .baseRequestData(.init(headers: headers))
        return .live(router: authenticatedRouter.baseURL(apiURI))
    }
}

extension APIClient.InvalidResponse {
    init(_ localizedDescription: String) {
        errorDescription = localizedDescription
    }
}

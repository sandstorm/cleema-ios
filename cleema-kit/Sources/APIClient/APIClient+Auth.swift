//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

public extension APIClient {
    @Sendable
    @discardableResult
    func login(user: String, password: String) async throws -> User {
        let client = URLRoutingClient.authenticated(apiURI: baseURI, token: .base(baseToken))
        let (data, response) = try await client.data(for: .authentication(.login(user: user, password: password)))
        guard let httpResponse = response as? HTTPURLResponse else { throw InvalidResponse() }
        if httpResponse.statusCode == 200 {
            authResponse = try JSONDecoder.isoDate.decode(AuthResponse.self, from: data)
            return try await me(pwd: password)
        } else {
            if let error = try JSONDecoder.isoDate.decode(APIResponse<AuthResponse>.self, from: data).error {
                throw APIError(from: error)
            }
            throw InvalidResponse()
        }
    }

    @Sendable
    func register(
        user: String,
        password: String,
        email: String,
        acceptsSurveys: Bool,
        regionID: Region.ID,
        avatarID: IdentifiedImage.ID?,
        clientID: UUID?,
        referralCode: String?
    ) async throws {
        let client = URLRoutingClient.authenticated(apiURI: baseURI, token: .base(baseToken))
        let (data, response) = try await client
            .data(for: .authentication(.register(.init(
                username: user,
                password: password,
                email: email,
                acceptsSurveys: acceptsSurveys,
                region: .init(uuid: regionID.rawValue),
                avatar: .init(id: avatarID?.rawValue),
                clientID: clientID,
                ref: referralCode
            ))))
        guard let httpResponse = response as? HTTPURLResponse else { throw InvalidResponse() }
        guard httpResponse.statusCode == 200 else {
            if let error = try JSONDecoder.isoDate.decode(APIResponse<AuthResponse>.self, from: data).error {
                throw APIError(from: error)
            }
            throw InvalidResponse()
        }
        let _: AuthResponse = try JSONDecoder.isoDate.decode(AuthResponse.self, from: data)
    }

    @Sendable
    func isAuthenticated(userID: Models.User.ID) async -> Bool {
        authResponse != nil
    }

    @Sendable
    func confirmAccount(code: String) async throws {
        let client = URLRoutingClient.live(router: apiRouter.baseURL(baseURI))
        let (_, response) = try await client
            .data(for: .authentication(.confirmAccount(code)))
        guard let httpResponse = response as? HTTPURLResponse else { throw InvalidResponse() }
        guard httpResponse.statusCode == 200 else {
            throw InvalidResponse()
        }
    }
}

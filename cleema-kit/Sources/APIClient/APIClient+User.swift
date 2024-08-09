//
//  Created by Kumpels and Friends on 03.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

public extension APIClient {
    @Sendable
    func me(pwd: String) async throws -> User {
        let result: UserBox = try await decoded(for: .user(.me), with: token)
        guard let user = User(rawValue: result.user, password: pwd, baseURL: baseURL) else {
            throw InvalidResponse()
        }
        return user
    }

    @Sendable
    func follows() async throws -> SocialGraph {
        let result: SocialGraphResponse = try await decoded(
            for: .user(.follows),
            with: token
        )
        return SocialGraph(rawValue: result, baseURL: baseURL)
    }

    @Sendable
    func unfollow(graphItemID: SocialGraphItem.ID) async throws -> SocialGraph {
        let result: SocialGraphResponse = try await decoded(
            for: .user(.unfollow(graphItemID.rawValue)),
            with: token
        )
        return SocialGraph(rawValue: result, baseURL: baseURL)
    }

    @Sendable
    func followInvitation(referralCode: String) async throws -> SocialGraphItem {
        do {
            let result: SocialGraphItemResponse = try await decoded(
                for: .user(.followInvitation(referralCode)),
                with: token
            )
            return SocialGraphItem(rawValue: result, baseURL: baseURL)
        } catch {
            throw FollowInvitationError(underlyingError: error)
        }
    }

    @Sendable
    func deleteUser(userID: User.ID) async throws {
        let client = URLRoutingClient.authenticated(apiURI: baseURI, token: token)
        let (_, response) = try await client.data(for: .user(.delete(userID.rawValue)))

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw InvalidResponse()
        }

        deauthorize()
    }

    @Sendable
    func updateUser(userID: User.ID, user: EditUser) async throws {
        let client = URLRoutingClient.authenticated(apiURI: baseURI, token: token)
        let (data, response) = try await client.data(for: .user(.update(userID.rawValue, .init(user: user))))

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            if let error = try JSONDecoder.isoDate.decode(APIResponse<AuthResponse>.self, from: data).error {
                throw APIError(from: error)
            }
            throw InvalidResponse()
        }
    }
}

struct FollowInvitationError: LocalizedError {
    var underlyingError: Error

    var errorDescription: String? {
        (underlyingError as? APIError)?.errorDetails
    }
}

//
//  Created by Kumpels and Friends on 12.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

public extension APIClient {
    @Sendable
    func challengeTemplates() async throws -> [Challenge] {
        let result: [ChallengeTemplateResponse] = try await decoded(
            for: .challengeTemplates,
            with: token
        )
        return result.compactMap { Challenge(rawValue: $0, baseURL: baseURL) }
    }

    @Sendable
    func challenges(for region: Region? = nil) async throws -> [Challenge] {
        let result: [ChallengeResponse] = try await decoded(
            for: .challenges(.region(region?.id.rawValue)),
            with: token
        )
        return result.compactMap { Challenge(rawValue: $0, baseURL: baseURL) }
    }

    @Sendable
    func joinedChallenges() async throws -> [JoinedChallenge] {
        let result: [ChallengeResponse] = try await decoded(for: .challenges(.joined), with: token)
        return result.compactMap { JoinedChallenge(rawValue: $0, baseURL: baseURL) }
    }

    @Sendable func join(challengeWithID id: Challenge.ID) async throws -> Challenge {
        let response: ChallengeResponse = try await decoded(
            for: .challenges(.challenge(id.rawValue, .join)),
            with: token
        )
        guard let challenge = Challenge(rawValue: response, baseURL: baseURL)
        else { throw InvalidResponse("ChallengeResponse not convertible to Challenge.") }
        return challenge
    }

    @Sendable func leave(challengeWithID id: Challenge.ID) async throws -> Challenge {
        let response: ChallengeResponse = try await decoded(
            for: .challenges(.challenge(id.rawValue, .leave)),
            with: token
        )
        guard let challenge = Challenge(rawValue: response, baseURL: baseURL)
        else { throw InvalidResponse("ChallengeResponse not convertible to Challenge.") }
        return challenge
    }

    @Sendable func update(joinedChallenge: JoinedChallenge) async throws {
        let req = AnswerRequest(
            answers: joinedChallenge.answers
                .map { .init(answer: .init(rawValue: $0.value), dayIndex: $0.key) }
        )
        let _: ChallengeResponse = try await decoded(
            for: .challenges(.challenge(
                joinedChallenge.id.rawValue,
                .answer(req)
            )),
            with: token
        )
    }

    @Sendable func save(challenge: Challenge, participants: Set<SocialUser.ID>) async throws -> Challenge {
        guard let request = CreateChallengeRequest(challenge: challenge, participants: participants)
        else { throw InvalidRequest() }

        let response: ChallengeResponse = try await decoded(
            for: .challenges(.create(.init(data: request))),
            with: token
        )
        guard let savedChallenge = Challenge(rawValue: response, baseURL: baseURL)
        else { throw InvalidResponse("ChallengeResponse not convertible to Challenge.") }
        return savedChallenge
    }

    @Sendable func challenge(by id: Challenge.ID) async throws -> Challenge {
        let response: ChallengeResponse = try await decoded(
            for: .challenges(.challenge(id.rawValue)),
            with: token
        )
        guard let challenge = Challenge(rawValue: response, baseURL: baseURL)
        else { throw InvalidResponse("ChallengeResponse not convertible to Challenge.") }
        return challenge
    }
}

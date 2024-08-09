//
//  Created by Kumpels and Friends on 12.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

public struct ChallengesClient {
    public var partnerChallenges: @Sendable (Region) -> AsyncThrowingStream<[Challenge], Error>
    public var joinPartnerChallenge: @Sendable (Challenge.ID) async throws -> Challenge
    public var joinedChallenges: @Sendable () -> AsyncStream<[JoinedChallenge]>
    public var leaveChallenge: @Sendable (JoinedChallenge.ID) async throws -> Challenge
    public var updateJoinedChallenge: @Sendable (JoinedChallenge) async throws -> Void
    public var fetchTemplates: @Sendable () async throws -> [Challenge]
    public var save: @Sendable (Challenge, Set<SocialUser.ID>) async throws -> Challenge
    public var challengeByID: @Sendable (Challenge.ID) async throws -> Challenge

    public init(
        partnerChallenges: @escaping @Sendable (Region) -> AsyncThrowingStream<[Challenge], Error>,
        joinPartnerChallenge: @escaping @Sendable (Challenge.ID) async throws -> Challenge,
        joinedChallenges: @escaping @Sendable () -> AsyncStream<[JoinedChallenge]>,
        leaveChallenge: @escaping @Sendable (JoinedChallenge.ID) async throws -> Challenge,
        updateJoinedChallenge: @escaping @Sendable (JoinedChallenge) async throws -> Void,
        fetchTemplates: @escaping @Sendable () async throws -> [Challenge],
        save: @escaping @Sendable (Challenge, Set<SocialUser.ID>) async throws -> Challenge,
        challengeByID: @escaping @Sendable (Challenge.ID) async throws -> Challenge
    ) {
        self.partnerChallenges = partnerChallenges
        self.joinPartnerChallenge = joinPartnerChallenge
        self.joinedChallenges = joinedChallenges
        self.leaveChallenge = leaveChallenge
        self.updateJoinedChallenge = updateJoinedChallenge
        self.fetchTemplates = fetchTemplates
        self.save = save
        self.challengeByID = challengeByID
    }
}

public extension ChallengesClient {
    struct InvalidInputError: Error { var localizedDescription: String = "Invalid request" }

    static let noop: Self = ChallengesClient(
        partnerChallenges: { _ in AsyncThrowingStream { _ in } },
        joinPartnerChallenge: { _ in .fake() },
        joinedChallenges: { AsyncStream { $0.finish() } },
        leaveChallenge: { _ in .fake() },
        updateJoinedChallenge: { _ in },
        fetchTemplates: { [] },
        save: { _, _ in .fake() },
        challengeByID: { _ in .fake() }
    )

    static let unimplemented: Self = ChallengesClient(
        partnerChallenges: XCTestDynamicOverlay.unimplemented(
            "\(Self.self).partnerChallenges",
            placeholder: AsyncThrowingStream { _ in }
        ),
        joinPartnerChallenge: XCTestDynamicOverlay.unimplemented(
            "\(Self.self).joinPartnerChallenge",
            placeholder: .fake()
        ),
        joinedChallenges: XCTestDynamicOverlay.unimplemented(
            "\(Self.self).joinedChallenges",
            placeholder: AsyncStream { _ in }
        ),
        leaveChallenge: XCTestDynamicOverlay.unimplemented("\(Self.self).leaveChallenge", placeholder: .fake()),
        updateJoinedChallenge: XCTestDynamicOverlay.unimplemented("\(Self.self).updateJoinedChallenge"),
        fetchTemplates: XCTestDynamicOverlay.unimplemented("\(Self.self).fetchTemplates", placeholder: []),
        save: XCTestDynamicOverlay.unimplemented("\(Self.self).save", placeholder: .fake()),
        challengeByID: XCTestDynamicOverlay.unimplemented("\(Self.self).challengeByID", placeholder: .fake())
    )

    static let preview: Self = {
        let challenges: [Challenge] = (1 ... 20)
            .map { .fake(title: "Challenge \($0)", kind: .partner(.fake())) }
        let partner = ActorIsolated(challenges)
        let joined = ActorIsolated<[JoinedChallenge]>([])

        return ChallengesClient(
            partnerChallenges: { region in
                AsyncThrowingStream { continuation in
                    continuation.yield(challenges.filter { $0.region == region })
                }
            },
            joinPartnerChallenge: { id in
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)
                guard let challenge = await partner.value.first(where: { $0.id == id })
                else { throw InvalidInputError() }
                await partner.withValue {
                    $0.removeAll { $0.id == id }
                }
                await joined.withValue { $0.append(.init(challenge: challenge)) }
                return challenge
            },
            joinedChallenges: {
                AsyncStream { cont in
                    cont.yield([.fake(), .fake(), .fake()])
                }
            },
            leaveChallenge: { id in
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)

                guard let index = await joined.value.firstIndex(where: { $0.id == id })
                else { throw InvalidInputError("Challenge with id \(id) not found.") }

                let left = await joined.withValue {
                    $0.remove(at: index)
                }

                guard left.challenge.isPartner else { return left.challenge }
                await partner.withValue {
                    $0.append(left.challenge)
                }
                return left.challenge
            },
            updateJoinedChallenge: { c in
                await joined.withValue { value in
                    guard let idx = value.firstIndex(where: { $0.id == c.id }) else { return }
                    value[idx] = c
                }
            },
            fetchTemplates: { [.fake(), .fake(), .fake()] },
            save: { challenge, _ in
                challenges.first { $0.id == challenge.id } ?? .fake()
            },
            challengeByID: { id in
                challenges.first { $0.id == id } ?? .fake()
            }
        )
    }()
}

public enum ChallengesClientKey: TestDependencyKey {
    public static let previewValue: ChallengesClient = .preview
    public static let testValue: ChallengesClient = .unimplemented
}

public extension DependencyValues {
    var challengesClient: ChallengesClient {
        get { self[ChallengesClientKey.self] }
        set { self[ChallengesClientKey.self] = newValue }
    }
}

extension ChallengesClient.InvalidInputError {
    init(_ localizedDescription: String = "Invalid Input") {
        self.localizedDescription = localizedDescription
    }
}

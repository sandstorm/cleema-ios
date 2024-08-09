//
//  Created by Kumpels and Friends on 10.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import APIClient
import AsyncAlgorithms
import Dependencies
import Foundation
import Models

public extension ChallengesClient {
    static func live(from apiClient: APIClient) -> Self {
        let updateChannel = AsyncChannel<Void>()
        return .init(
            partnerChallenges: { region in
                AsyncThrowingStream { cont in
                    let task = Task {
                        cont.yield(try await apiClient.challenges(for: region))
                        for await _ in updateChannel {
                            guard !Task.isCancelled else {
                                cont.finish()
                                return
                            }
                            cont.yield(try await apiClient.challenges(for: region))
                        }
                    }
                    cont.onTermination = { _ in
                        // FIXME: cancellation here will break the app...
//                        task.cancel()
                    }
                }
            },
            joinPartnerChallenge: { id in
                let challenge = try await apiClient.join(challengeWithID: id)
                await updateChannel.send(())
                return challenge
            },
            joinedChallenges: {
                AsyncStream { cont in
                    let task = Task {
                        cont.yield(try await apiClient.joinedChallenges())
                        for await _ in updateChannel {
                            guard !Task.isCancelled else {
                                cont.finish()
                                return
                            }
                            cont.yield(try await apiClient.joinedChallenges())
                        }
                    }
                    cont.onTermination = { _ in
                        // FIXME: cancellation here will break the app...
//                        task.cancel()
                    }
                }
            },
            leaveChallenge: { id in
                let challenge = try await apiClient.leave(challengeWithID: id)
                await updateChannel.send(())
                return challenge
            },
            updateJoinedChallenge: { joinedChallenge in
                try await apiClient.update(joinedChallenge: joinedChallenge)
                await updateChannel.send(())
            },
            fetchTemplates: {
                try await apiClient.challengeTemplates()
            },
            save: { challenge, participants in
                let savedChallenge = try await apiClient.save(challenge: challenge, participants: participants)
                await updateChannel.send(())
                return savedChallenge
            },
            challengeByID: { id in
                try await apiClient.challenge(by: id)
            }
        )
    }
}

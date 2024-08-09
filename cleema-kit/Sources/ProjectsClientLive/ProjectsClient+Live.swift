//
//  Created by Kumpels and Friends on 09.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import APIClient
import AsyncAlgorithms
import Foundation
import Logging
import Models

public extension ProjectsClient {
    static func live(from apiClient: APIClient, log: Logging) -> Self {
        let favChannel = AsyncChannel<Void>()
        return .init(
            projects: apiClient.projects(for:),
            join: apiClient.join(projectID:),
            leave: apiClient.leave(projectID:),
            support: { _, _ in
                log.info("Supporting projects is unimplemented")
            },
            fav: { projectID, shouldBeFaved in
                let project = try await apiClient.fav(projectID: projectID, shouldBeFaved: shouldBeFaved)
                Task {
                    await favChannel.send(())
                }
                return project
            },
            favedProjectsStream: {
                AsyncThrowingStream { cont in
                    let task = Task {
                        do {
                            cont.yield(try await apiClient.favedProjects())
                            for await _ in favChannel {
                                let value = try await apiClient.favedProjects()
                                switch cont.yield(value) {
                                case let .enqueued(remaining: remaining):
                                    log.debug("Enqueued, remaining \(remaining)")
                                case let .dropped(element):
                                    log.debug("Dropped", userInfo: ["element": element])
                                case .terminated:
                                    log.debug("Could not send value")
                                @unknown default:
                                    break
                                }
                            }
                        } catch {
                            log.error("Error loading faved projects", userInfo: error.logInfo)
                        }
                    }
                    cont.onTermination = { _ in
                        task.cancel()
                    }
                }
            }
        )
    }
}

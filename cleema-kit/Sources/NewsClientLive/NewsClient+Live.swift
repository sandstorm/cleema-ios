//
//  Created by Kumpels and Friends on 09.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import APIClient
import AsyncAlgorithms
import Foundation
import Logging
import NewsClient

public extension NewsClient {
    static func from(_ client: APIClient, log: Logging) -> Self {
        let favChannel = AsyncChannel<Void>()

        return .init(
            news: client.news,
            tags: client.tags,
            fav: { id, isFaved in
                let news = try await client.fav(newsID: id, shouldBeFaved: isFaved)
                Task {
                    await favChannel.send(())
                }
                return news
            },
            favedNewsStream: {
                AsyncThrowingStream { cont in
                    let task = Task {
                        do {
                            cont.yield(try await client.favedNews())
                            for await _ in favChannel {
                                cont.yield(try await client.favedNews())
                            }
                        } catch {
                            log.error("Error fetching faved news", userInfo: error.logInfo)
                        }
                    }
                    cont.onTermination = { _ in
                        task.cancel()
                    }
                }
            },
            markAsRead: { id in
                try await client.markAsRead(newsID: id)
            }
        )
    }
}

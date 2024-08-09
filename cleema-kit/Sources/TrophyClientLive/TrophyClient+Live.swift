//
//  Created by Kumpels and Friends on 29.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import APIClient
import TrophyClient

public extension TrophyClient {
    static func live(from apiClient: APIClient) -> Self {
        .init(
            loadTrophies: {
                try await apiClient.trophies()
            },
            newTrophies: {
                try await apiClient.newTrophies()
            }
        )
    }
}

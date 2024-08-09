//
//  Created by Kumpels and Friends on 14.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import AvatarClient

public extension AvatarClient {
    static func live(from apiClient: APIClient) -> Self {
        .init(loadAvatars: apiClient.avatars)
    }
}

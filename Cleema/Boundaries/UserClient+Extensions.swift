//
//  Created by Kumpels and Friends on 21.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import Foundation
import UserClientLive

extension UserClientKey: DependencyKey {
    public static let liveValue = UserClient.live(apiClient: APIClient.shared)
}

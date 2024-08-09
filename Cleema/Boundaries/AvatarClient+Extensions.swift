//
//  Created by Kumpels and Friends on 24.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import AvatarClientLive
import Foundation

extension AvatarClientKey: DependencyKey {
    public static let liveValue: AvatarClient = .live(from: APIClient.shared)
}

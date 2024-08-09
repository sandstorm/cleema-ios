//
//  Created by Kumpels and Friends on 21.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import Dependencies
import Foundation
import InfoClientLive

extension InfoClientKey: DependencyKey {
    public static let liveValue = InfoClient.live(from: APIClient.shared)
}

//
//  Created by Kumpels and Friends on 21.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import ChallengesClientLive
import Foundation

extension ChallengesClientKey: DependencyKey {
    public static let liveValue: ChallengesClient = .live(from: APIClient.shared)
}

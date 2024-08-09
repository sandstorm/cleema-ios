//
//  Created by Kumpels and Friends on 19.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import APIClient
import BecomeSponsorClientLive
import Foundation

extension BecomeSponsorClientKey: DependencyKey {
    public static var liveValue: BecomeSponsorClient = .live(from: APIClient.shared)
}
